from typing import List
from compiler import c, dotnet, ghc, go, java, mono, python, rust, nim
from compiler.helper import Response2, Problem2, run_command, prefix


def run(cmd: str, working_directory: str, files: List[str]) -> Response2:
    '''Run a compiler'''

    rslt = None

    if cmd.startswith("gcc ") or cmd.startswith("clang ") or cmd.startswith("g++ ") or cmd.startswith("zig "):
        rslt = c.run(cmd, working_directory)

    elif cmd.startswith("dotnet "):
        rslt = dotnet.run(cmd, working_directory)

    elif cmd.startswith("ghc "):
        rslt = ghc.run(cmd, working_directory)

    elif cmd.startswith("go "):
        rslt = go.run(cmd, working_directory)

    elif cmd.startswith("javac "):
        rslt = java.run(cmd, working_directory)

    elif cmd.startswith("mcs "):
        rslt = mono.run(cmd, working_directory)

    elif cmd.startswith("nim "):
        rslt = nim.run(cmd, working_directory)

    elif cmd.startswith("python "):
        rslt = python.run(cmd, working_directory)

    elif cmd.startswith("rustc "):
        rslt = rust.run(cmd, working_directory)

    elif cmd.startswith("none"):
        rslt = {"ok": True, "message": "", "problems": []}

    else:
        out = run_command(prefix + cmd, working_directory)
        rslt = {"ok": not len(out.stderr) > 0,
                "message": out.stdout + out.stderr,
                "problems": []}

    return {"ok": rslt["ok"],
            "uid": None,
            "message": rslt["message"],
            "problems": formatting(files, rslt["problems"])}


def formatting(files: List[str], problems) -> List[List[Problem2]]:
    '''
    Translate the list of problems into a nested list of Problems,
    where problems within a single file are chunked by their order
    in the files list.
    '''

    if len(problems) == 0:
        return []

    rslt: List[List[Problem2]] = [[]] * len(files)

    index = {}

    for (i, file) in enumerate(files):
        index[file] = i

    for prob in problems:
        rslt[index[prob["file"]]].append(
            {"type": prob["type"],
             "row": prob["row"],
             "col": prob["col"],
             "text": prob["text"]
             })

    return rslt
