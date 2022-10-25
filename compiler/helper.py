'''
Custom Helper functions and response and problem types...
'''

import re
import subprocess
from typing import Tuple, List, Any, TypedDict


prefix = "firejail --noroot --private --quiet --cpu=1 --nonewprivs --nogroups --nice=19 --hostname=host --net=none --no3d --nosound --x11=none --rlimit-cpu=1 -- timeout 300 "


Problem = TypedDict("Problem", {"file": str,
                                "type": str,
                                "row": int,
                                "col": int,
                                "text": str})


Response = TypedDict("Response", {"ok": bool,
                                  "message": str,
                                  "problems": List[Problem]})


Problem2 = TypedDict("Problem2", {"type": str,
                                  "row": int,
                                  "col": int,
                                  "text": str
                                  })


Response2 = TypedDict("Response2", {"ok": bool,
                                    "message": str,
                                    "uid": str | None,
                                    "problems": List[List[Problem2]]
                                    })


class OutputDummy(object):
    '''
    A dummy class to provide and output if subprocess.run fails...
    '''

    def __init__(self, error: str):
        self.error = error

    def stdout(self):
        '''Empty stdout output.'''
        return ""

    def stderr(self):
        '''Return the error message.'''
        return self.error


def run_command(cmd: str, cwd: str) -> Any:
    '''
    Run an arbitrary command within the current working directory.
    '''

    try:
        out = subprocess.run(cmd,
                             cwd=cwd,
                             capture_output=True,
                             text=True,
                             shell=True)
    except Exception as error:
        out = OutputDummy(str(error))

    return out


def c_like_find_all(kind: str, pattern: str, output: str) -> List[Problem]:
    '''
    Detect all occurrences of pattern within an output-string.
    '''

    return c_like_formatting(re.findall("\\.?/?([^:\\s]+):(\\d+):(\\d+)"
                                        + pattern +
                                        " ([^\n]+)", output), kind)


def c_like_formatting(problems: List[Tuple[str, str, str, str]], kind: str) -> List[Problem]:
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


def escape_ansi(line):
    '''
    Remove ansi escape chars
    '''
    try:
        ansi_escape = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]')
        return ansi_escape.sub('', line)
    except Exception as _:
        return line
