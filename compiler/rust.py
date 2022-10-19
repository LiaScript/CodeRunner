import re
from typing import List, Tuple
from compiler.helper import Response, Problem, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the rusts compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)

    errors = find_errors(out.stderr) + find_errors(out.stdout)

    return {
        "ok": len(errors) == 0,
        "message": out.stdout + out.stderr,
        "problems": errors
    }


def find_errors(output: str) -> List[Problem]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return formatting(re.findall("error\\[?[^\\]:]*\\]?: (.*)\n\\s+\\-\\->\\s*([^:]*):(\\d+):(\\d+)", output), "error")


def formatting(problems: List[Tuple[str, str, str, str]], kind: str) -> List[Problem]:
    '''
    Turn a list of strings into a predefined format of type problem, which is used by the
    remote editor to display errors. 
    '''

    result = []

    for (msg, file, row, col) in problems:
        result.append(Problem({"file": file,
                               "type": kind,
                               "row": int(row) - 1,
                               "col": int(col),
                               "text": msg}))

    return result
