from threading import Thread
import os
import shutil
import tempfile
import json
import logging
from typing import List
import pathlib
import base64
import getopt
import sys
import coloredlogs
from websocket_server import WebsocketServer
import pexpect
import compiler
from compiler.helper import run_command, prefix, escape_ansi

coloredlogs.install()


class Process:
    '''
    A process is a running execution within a thread, that sends back received inputs from stdin.
    '''

    def __init__(self, current_directory: str, cmd: str, callback, stop):
        self.stdin: List[str] = []
        self.current_directory = current_directory
        self.callback = callback
        self.stop = stop
        self.error = None

        try:
            self.process = pexpect.spawn(cmd, cwd=current_directory, echo=False, encoding="utf-8")
            self.process.timeout = None
        except Exception as error:
            self.error = str(error)

    def __del__(self):
        self.destroy()

    def destroy(self):
        '''
        Try to terminate the process immediately.
        '''
        try:
            self.process.terminate(force=True)
        except Exception as _:
            pass

        try:
            self.process.close(force=True)
        except Exception as _:
            pass

        try:
            del self.callback
        except Exception as _:
            pass

        try:
            del self.process
        except Exception as _:
            pass

    def is_alive(self) -> bool:
        '''
        Test if the process is still running.
        '''

        try:
            return self.process.isalive()
        except Exception as _:
            return False

    def input(self, stdin: str) -> None:
        '''
        Receive strings that should be send to stdin of a running process.
        '''
        self.stdin.append(stdin)
        print("Stdin", stdin)

    def spawn(self) -> None:
        '''
        Spawn a new process and listen to stdout as long as the process is alive.
        '''
        while self.read_line() or self.is_alive():
            try:
                if len(self.stdin) > 0:
                    print("input", self.stdin)
                    input_string = self.stdin.pop(0)

                    if input_string.endswith("\n"):
                        input_string = input_string[0:-1]

                    self.process.sendline(input_string)
                    # self.process.expect(input_string)
            except Exception as _:
                pass

        # self.process.expect(pexpect.EOF)
        # print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW", self.process.before)

        self.process.close()

        self.stop(None, self.list_images())

    def list_images(self):
        '''
        Search the current directory for all generated images and return them as base46.
        '''

        files = os.listdir(self.current_directory)

        files = list(map(lambda filename: self.current_directory + "/" + filename, files))

        files = sorted(filter(os.path.isfile, files), key=os.path.getmtime, reverse=True)

        images = []
        for filename in files:
            extension = pathlib.Path(filename).suffix.lower()[1:]

            if extension in ["bmp", "gif", "jpg", "jpeg", "png", "svg", "tif"]:

                with open(filename, "rb") as img_file:
                    images += [{"file": pathlib.Path(filename).name, "data": "data:image/" + extension +
                                ";base64," + base64.b64encode(img_file.read()).decode("utf8")}]

        return images

    def read_line(self) -> bool:
        '''
        Read in a bunch of max 2000 characters from stdin and send them back to
        the associated web-socket connection (callback).
        '''

        stdout = ""

        try:
            stdout = self.process.read_nonblocking(size=2000, timeout=0)
        except Exception as _:
            pass

        if stdout:
            self.callback(stdout)
            return True

        return False


class Project:
    '''
    A project is a container for a temporary folder.
    All files within this folder will be deleted when a project gets destroyed.
    Additionally a process can be associated to project, which spawns an external execution,
    that send stdout messages and receives stdin inputs.
    '''

    def __init__(self, uid: str):
        self.uid: str = uid
        self.dir: str = tempfile.mkdtemp()
        self.filenames: List[str] = []

        self.process: Process | None
        self.thread: Thread | None

    def __del__(self):
        self.destroy()

    def exec(self, cmd: str, stdin, stop):
        '''
        This will spawn a new and persistent process, that will run in background.
        It will send continuos messages back to the web-socket connection and a
        finish message, when it is done. 
        '''
        try:
            self.process.destroy()
        except Exception as _:
            pass

        # clean up leading spaces
        cmd = cmd.lstrip()

        if cmd.startswith("dotnet "):
            self.process = Process(self.dir, "timeout 60 nice -19 " + cmd, stdin, stop)
        else:
            self.process = Process(self.dir, prefix + cmd, stdin, stop)

        if self.process.error:
            stop(self.process.error)

        else:
            self.thread = Thread(target=self.process.spawn)
            self.thread.start()

    def input(self, stdin: str):
        '''Send inputs to stdin to a running process.'''
        if self.process:
            self.process.input(stdin)

    def run(self, cmd: str):
        '''
        Directly run a subprocess and wait for the output.
        '''

        output = run_command(prefix + cmd, self.dir)

        if len(output.stderr) > 0:
            return {"ok": False,
                    "uid": self.uid,
                    "response": output.stderr}

        return {"ok": True,
                "uid": self.uid,
                "response": output.stdout}

    def compile(self, cmd: str):
        '''
        Perform a compilation and send back the success or error messages.
        '''

        rslt = compiler.run(cmd, self.dir, self.filenames)
        rslt["uid"] = self.uid
        return rslt

    def kill(self):
        '''
        Kill the process if it is running.
        '''

        self.process.destroy()

    def destroy(self):
        '''
        Kill all the process and delete all associated project files.
        '''

        try:
            self.process.destroy()
        except Exception as _:
            pass

        try:
            shutil.rmtree(self.dir)
        except Exception as _:
            pass

    def add_files(self, files: list[tuple[str, str]]) -> None:
        '''Store a list of files, that consist of pairs of [filename, content]
           within the predefined temporary folder.'''

        self.filenames = []

        for (filename, content) in files:
            self.filenames.append(filename)
            filepath = os.path.join(self.dir, filename)

            if not os.path.isdir(os.path.dirname(filepath)):
                os.makedirs(os.path.dirname(filepath))

            file = open(filepath, "w", encoding='utf8')
            file.write(content + "\n")
            file.close()


def new_client(client, _):
    '''
    Called for every client connecting (after handshake)
    '''

    logging.info("New client connected and was given id %s", client['id'])
    # server.send_message_to_all("Hey all, a new client has joined us")
    client["project"] = dict()


def client_left(client, _):
    '''
    Called for every client disconnecting
    '''

    if client == None:
        return

    logging.info("Client disconnected with id %s", client["id"])

    # delete all associated files and kill all running processes
    try:
        for project in client["project"].values():
            project.destroy()
    except Exception as err:
        logging.warning("client left with => %s", err)


# Called when a client sends a message
def message_received(client, _, message) -> None:
    '''
    # Global message handler

    Every message must have an `uid` and messages have to contain one of the
    following fields:

    * `data`:

      This means that a bunch of files arrive, that are stored within the
      temporary folder, that is associated with the project. This can be
      associated to any message.

    * `compile`:

      this requires an compilation command, currently supported are:

      - gcc


    * `run`:
    * `exec`:
    * `input`:

      This message shall contain stdin messages that are send to a
      running process.

    * `stop`: stop the process

    '''

    logging.debug("Client with id %s received: %s", client["id"], message)

    if message == "ping":
        return

    message = json.loads(message)

    if "uid" not in message:
        logging.warning("received message without uid => %s", json.dumps(message, indent=2))

        return

    if not message["uid"] in client["project"]:
        client["project"][message["uid"]] = Project(message["uid"])

    if "data" in message:
        logging.debug("Client(%d) => %s", client['id'], message["data"])
        client["project"][message["uid"]].add_files(message["data"])
        response = {"ok": True, "uid": message["uid"], "service": "data"}
        server.send_message(client, json.dumps(response))

    if "compile" in message:
        response = client["project"][message["uid"]].compile(message["compile"])
        response["service"] = "compile"
        server.send_message(client, json.dumps(response))

    if "run" in message:
        response = client["project"][message["uid"]].run(message["run"])
        response["service"] = "run"
        server.send_message(client, json.dumps(response))

    if "exec" in message:
        def stdout(data):
            server.send_message(client, json.dumps(
                {"ok": True,
                 "service": "stdout",
                 "uid": message["uid"],
                 "data": escape_ansi(data)}))

        def stop(error_message: str | None = None, images=[]):
            resp = {"ok": True, "service": "stop", "uid": message["uid"]}

            if error_message:
                resp["error"] = error_message

            if len(images) > 0:
                resp["images"] = images

            server.send_message(client, json.dumps(resp))

        client["project"][message["uid"]].exec(message["exec"], stdout, stop)

    if "stdin" in message:
        client["project"][message["uid"]].input(message["stdin"])

    if "stop" in message:
        client['project'][message["uid"]].kill()
        server.send_message(client, json.dumps({"ok": True, "service": "stop", "uid": message["uid"]}))


if __name__ == "__main__":
    argv = sys.argv[1:]

    PORT = int(os.environ.get('CODERUNNER_PORT') or '8000')
    HOST = os.environ.get('CODERUNNER_HOST') or '127.0.0.1'

    options, args = getopt.getopt(argv, "p:h", ["port=", "host=", "help"])

    for opt, arg in options:
        if opt in ('-p', '--port'):
            PORT = int(arg)
        elif opt == "--host":
            HOST = arg
        elif opt in ("-h", "--help"):
            print("CodeRunner")
            print()
            print("  This service is meant to be used with LiaScript and its CodeRunner implementation in")
            print("  order to run execute small peaces of code as a web-service.")
            print()
            print("Options:")
            print()
            print("  -h, --help   Print out the help")
            print("  -p, --port   Set the server port, this will overwrite the env-variable CODERUNNER_PORT")
            print("               ... defaults to 8000")
            print("  --host       Set the server host, this will overwrite the env-variable CODERUNNER_HOST")
            print("               ... defaults to 127.0.0.1")
            exit(0)

    server = WebsocketServer(host=HOST, port=PORT)

    server.set_fn_new_client(new_client)
    server.set_fn_client_left(client_left)
    server.set_fn_message_received(message_received)

    logging.basicConfig(level=logging.DEBUG)

    logging.info("starting server on %s:%s", HOST, PORT)

    server.run_forever()
