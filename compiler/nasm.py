import re
from typing import List, Tuple
from compiler.helper import Response, Problem, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the nasm compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)

    warnings = find_warnings(out.stderr) + find_warnings(out.stdout)
    errors = find_errors(out.stderr) + find_errors(out.stdout)

    return {
        "ok": len(errors) == 0,
        "message": out.stdout + out.stderr,
        "problems": warnings + errors
    }


def find_warnings(output: str) -> List[Problem]:
    '''
    Detect all warnings within the gcc output.
    '''

    return find_all("warning", ": warning:", output)


def find_errors(output: str) -> List[Problem]:
    '''
    Detect all errors and fatal errors within the gcc output.
    '''

    err1 = find_all("error", ": error:", output)
    err2 = find_all("error", ": fatal error:", output)

    return err1 + err2


def find_all(kind: str, pattern: str, output: str) -> List[Problem]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return formatting(re.findall("\\.?/?([^:\\s]+):(\\d+)"
                                 + pattern +
                                 " ([^\n]+)", output), kind)


def formatting(problems: List[Tuple[str, str, str]], kind: str) -> List[Problem]:
    '''
    Turn a list of strings into a predefined format of type problem, which is used by the
    remote editor to display errors.
    '''

    result = []

    for (file, row, msg) in problems:
        result.append(Problem({"file": file,
                               "type": kind,
                               "row": int(row) - 1,
                               "col": 0,
                               "text": msg}))

    return result
