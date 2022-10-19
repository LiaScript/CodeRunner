from typing import List
from compiler.helper import Response, Problem, c_like_find_all, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the gcc compiler with the given command within the current working directory.
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

    return c_like_find_all("warning", ": warning:", output)


def find_errors(output: str) -> List[Problem]:
    '''
    Detect all errors and fatal errors within the gcc output.
    '''

    err1 = c_like_find_all("error", ": error:", output)
    err2 = c_like_find_all("error", ": syntax error:", output)

    return err1 + err2
