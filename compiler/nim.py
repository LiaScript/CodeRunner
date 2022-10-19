from typing import List, Tuple
import re
from compiler.helper import Response, Problem, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the nim compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)

    warnings = find_warnings(out.stderr) + find_warnings(out.stdout)
    errors = find_errors(out.stderr) + find_errors(out.stdout)

    return {
        "ok": len(errors) == 0,
        "message": out.stdout + out.stderr,
        "problems": warnings + errors
    }


def find_all(pattern: str, output: str) -> List[Tuple[str, str, str, str]]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return re.findall("/tmp/[^/]+/([^\\(]+)\\((\\d+), (\\d+)\\) " + pattern + ": (.*)", output)


def find_warnings(output: str) -> List[Problem]:
    '''
    Detect all warnings within the gcc output.
    '''

    return formatting(find_all("Warning", output), "warning")


def find_errors(output: str) -> List[Problem]:
    '''
    Detect all errors and fatal errors within the gcc output.
    '''

    return formatting(find_all("Error", output), "error")


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
