"""
Gleam support for CodeRunner.

A Gleam program has to live inside a project (gleam.toml + src/), and the
standard library has to be downloaded from Hex before the first build. The
execution sandbox has no network, so the Docker image contains a prepared
template project (GLEAM_TEMPLATE) with gleam_stdlib already downloaded and
compiled. Before building, the template is copied into the working directory,
unless the course sends its own gleam.toml.
"""

import os
import re
import shutil

from compiler.helper import Problem, Response, escape_ansi, run_command

TEMPLATE = os.environ.get("GLEAM_TEMPLATE", "/opt/gleam-template")

# error: Type mismatch
#   ┌─ /tmp/tmpab12cd/src/main.gleam:4:14
PATTERN = re.compile(
    r"^(error|warning): ([^\n]+)\n\s*┌─ ([^\n]+?):(\d+):(\d+)", re.MULTILINE
)


def prepare(cwd: str) -> None:
    """Copy the template project into the working directory, if needed."""

    if os.path.exists(os.path.join(cwd, "gleam.toml")):
        return

    if os.path.isdir(TEMPLATE):
        shutil.copytree(TEMPLATE, cwd, dirs_exist_ok=True, symlinks=True)


def run(cmd: str, cwd: str) -> Response:
    """
    Run a gleam command (usually `gleam build`) within the working directory.
    """

    prepare(cwd)

    out = run_command(cmd, cwd)

    output = escape_ansi(out.stdout + out.stderr)
    problems = find_all(output, cwd)
    errors = [p for p in problems if p["type"] == "error"]

    return {
        "ok": len(errors) == 0 and getattr(out, "returncode", 1) == 0,
        "message": output,
        "problems": problems,
    }


def relative(path: str, cwd: str) -> str:
    """
    Gleam prints absolute paths, CodeRunner identifies files by the name that
    was sent by the course (for example `src/main.gleam`).
    """

    path = path.strip()

    if os.path.isabs(path):
        real_cwd = os.path.realpath(cwd)
        for base in (cwd, real_cwd):
            if path.startswith(base.rstrip("/") + "/"):
                return os.path.relpath(path, base)

        if "/src/" in path:
            return "src/" + path.split("/src/", 1)[1]

    return path.removeprefix("./")


def find_all(output: str, cwd: str) -> list[Problem]:
    """Detect all errors and warnings within the gleam output."""

    result = []

    for kind, msg, file, row, col in PATTERN.findall(output):
        result.append(
            Problem(
                {
                    "file": relative(file, cwd),
                    "type": kind,
                    "row": int(row) - 1,
                    "col": int(col),
                    "text": msg.strip(),
                }
            )
        )

    return result
