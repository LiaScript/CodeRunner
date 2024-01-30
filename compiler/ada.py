import re
from typing import List, Tuple
from compiler.helper import Response, Problem, run_command, c_like_find_all


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the ghc compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)
    warnings = find_warnings(out.stderr) + find_warnings(out.stdout)
    errors = find_errors(out.stderr) + find_errors(out.stdout)

    return {
        "ok": len(errors) == 0,
        "message": out.stdout + out.stderr,
        "problems": warnings + errors
    }


def find_all(pattern: str, output: str) -> List[Tuple[str, str, str]]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return re.findall("([^:\\s]+):(\\d+):(\\d+): "
                      + pattern +
                      ": ([^\n]+)", output)


def find_warnings(output: str) -> List[Problem]:
    '''
    Detect all warnings within the gcc output.
    '''

    return formatting(find_all("warning", output), "warning")


def find_errors(output: str) -> List[Problem]:
    '''
    Detect all errors and fatal errors within the gcc output.
    '''

    err1 = find_all("error", output)
    err2 = find_all("fatal error", output)

    return formatting(err1 + err2, "error")


def formatting(problems: List[Tuple[str, str, str, str]], kind: str) -> List[Problem]:
    '''
    Turn a list of strings into a predefined format of type problem, which is used by the
    remote editor to display errors. 
    '''

    result = []

    for (file, row, col, msg) in problems:
        result.append(Problem({"file": file,
                               "type": kind,
                               "row": int(row) - 1,
                               "col": int(col),
                               "text": msg}))

    return result
