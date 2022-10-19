from typing import List
from compiler.helper import Response, Problem, c_like_find_all, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the dotnet compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)

    return {
        "ok": True,
        "message": out.stdout + out.stderr,
        "problems": []
    }
