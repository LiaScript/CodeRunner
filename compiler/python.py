import re
from typing import Tuple, List
from compiler.helper import Response, Problem, run_command


def run(cmd: str, cwd: str) -> Response:
    '''
    Run the java compiler with the given command within the current working directory.
    '''

    out = run_command(cmd, cwd)

    problems = find_all(out.stderr) + find_all(out.stdout)

    return {
        "ok": len(problems) == 0,
        "message": out.stdout + out.stderr,
        "problems": formatting(problems, "error")
    }


def find_all(output: str) -> List[Tuple[str, str, str]]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return re.findall("File \"./([^\"]+)\", line (\\d)+\n.*\n.*\n(.*)", output)


def formatting(problems: List[Tuple[str, str,  str]], kind: str) -> List[Problem]:
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
