<!--
author:   André Dietrich

email:    LiaScript@web.de

version:  0.0.4

language: en

narrator: US English Female

@onload
window.CodeRunner = {
    ws: undefined,
    handler: {},
    connected: false,
    error: "",
    url: "",
    firstConnection: true,

    init(url, step = 0) {
        this.url = url
        if (step  >= 10) {
           console.warn("could not establish connection")
           this.error = "could not establish connection to => " + url
           return
        }

        this.ws = new WebSocket(url);

        const self = this
        
        const connectionTimeout = setTimeout(() => {
          self.ws.close();
          console.log("WebSocket connection timed out");
        }, 5000);
        
        
        this.ws.onopen = function () {
            clearTimeout(connectionTimeout);
            self.log("connections established");

            self.connected = true
            
            setInterval(function() {
                self.ws.send("ping")
            }, 15000);
        }
        this.ws.onmessage = function (e) {
            // e.data contains received string.

            let data
            try {
                data = JSON.parse(e.data)
            } catch (e) {
                self.warn("received message could not be handled =>", e.data)
            }
            if (data) {
                self.handler[data.uid](data)
            }
        }
        this.ws.onclose = function () {
            clearTimeout(connectionTimeout);
            self.connected = false
            self.warn("connection closed ... reconnecting")

            setTimeout(function(){
                console.warn("....", step+1)
                self.init(url, step+1)
            }, 1000)
        }
        this.ws.onerror = function (e) {
            clearTimeout(connectionTimeout);
            self.warn("an error has occurred")
        }
    },
    log(...args) {
        window.console.log("CodeRunner:", ...args)
    },
    warn(...args) {
        window.console.warn("CodeRunner:", ...args)
    },
    handle(uid, callback) {
        this.handler[uid] = callback
    },
    send(uid, message, sender=null, restart=false) {
        const self = this
        if (this.connected) {
          message.uid = uid
          this.ws.send(JSON.stringify(message))
        } else if (this.error) {

          if(restart) {
            sender.lia("LIA: terminal")
            this.error = ""
            this.init(this.url)
            setTimeout(function() {
              self.send(uid, message, sender, false)
            }, 2000)

          } else {
            //sender.lia("LIA: wait")
            setTimeout(() => {
              sender.lia(" " + this.error)
              sender.lia(" Maybe reloading fixes the problem ...")
              sender.lia("LIA: stop")
            }, 800)
          }
        } else {
          setTimeout(function() {
            self.send(uid, message, sender, false)
          }, 2000)
          
          if (sender) {
            
            sender.lia("LIA: terminal")
            if (this.firstConnection) {
              this.firstConnection = false
              setTimeout(() => { 
                sender.log("stream", "", [" Waking up execution server ...\n", "This may take up to 30 seconds ...\n", "Please be patient ...\n"])
              }, 100)
            } else {
              sender.log("stream", "", ".")
            }
            sender.lia("LIA: terminal")
          }
        }
    }
}

//window.CodeRunner.init("wss://coderunner.informatik.tu-freiberg.de/")
//window.CodeRunner.init("ws://localhost:4000/")
window.CodeRunner.init("wss://ancient-hollows-41316.herokuapp.com/")
@end


@LIA.ada:               @LIA.eval(`["main.ada"]`, `gnatmake main.ada`, `./main`)
@LIA.algol:             @LIA.eval(`["main.alg"]`, `none`, `a68g main.alg`)
@LIA.apl:               @LIA.eval(`["main.apl"]`, `none`, `dyalog -script main.apl`)
@LIA.awk:               @LIA.eval(`["main.awk"]`, `none`, `awk -f main.awk`)
@LIA.basic:             @LIA.eval(`["main.bas"]`, `none`, `bwbasic main.bas`)
@LIA.c:                 @LIA.eval(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)
@LIA.clojure:           @LIA.eval(`["main.clj"]`, `none`, `clojure -M main.clj`)
@LIA.clojure_withShell: @LIA.eval(`["main.clj"]`, `none`, `clojure -M -i main.clj -r`)
@LIA.cpp:               @LIA.eval(`["main.cpp"]`, `g++ main.cpp -o a.out`, `./a.out`)
@LIA.cobol:             @LIA.eval(`["main.cob"]`, `cobc -x --free main.cob`, `./main`)
@LIA.coq:               @LIA.eval(`["file.v"]`, `coqc file.v`, `coqtop -lv file.v`)
@LIA.d:                 @LIA.eval(`["main.d"]`, `gdc main.d`, `./a.out`)
@LIA.elixir:            @LIA.eval(`["main.exs"]`, `none`, `elixir main.exs`)
@LIA.elixir_withShell:  @LIA.eval(`["main.exs"]`, `none`, `iex main.exs`)
@LIA.erlang:            @LIA.eval(`["hello.erl"]`, `erlc hello.erl`, `erl -noshell -s hello hello -s init stop`)
@LIA.erlang_withShell:  @LIA.eval(`["hello.erl"]`, `erlc hello.erl`, `erl -noshell -s hello hello`)
@LIA.forth:             @LIA.eval(`["main.fs"]`, `none`, `gforth main.fs -e BYE`)
@LIA.forth_withShell:   @LIA.eval(`["main.fs"]`, `none`, `gforth main.fs`)
@LIA.fortran:           @LIA.eval(`["main.f90"]`, `gfortran main.f90 -o a.out`, `./a.out`)
@LIA.go:                @LIA.eval(`["main.go"]`, `go build main.go`, `./main`)
@LIA.groovy:            @LIA.eval(`["main.groovy"]`, `none`, `groovy main.groovy`)
@LIA.haskell:           @LIA.eval(`["main.hs"]`, `ghc main.hs -o main`, `./main`)
@LIA.haskell_withShell: @LIA.eval(`["main.hs"]`, `none`, `ghci main.hs`)
@LIA.haxe:              @LIA.eval(`["Main.hx"]`, `none`, `haxe -main Main --interp`)
@LIA.inform:            @LIA.eval(`["main.inf"]`, `inform -o main.inf > compile.log && [ -f "main.z5" ] || { cat compile.log >&2; exit 1; }`, `/usr/games/dfrotz main.z5`)
@LIA.io:                @LIA.eval(`["main.io"]`, `none`, `io main.io`)
@LIA.io_withShell:      @LIA.eval(`["main.io"]`, `none`, `io -i main.io`)
@LIA.java:              @LIA.eval(`["@0.java"]`, `javac @0.java`, `java @0`)
@LIA.julia:             @LIA.eval(`["main.jl"]`, `none`, `julia main.jl`)
@LIA.julia_withShell:   @LIA.eval(`["main.jl"]`, `none`, `julia -i main.jl`)
@LIA.kotlin:            @LIA.eval(`["main.kt"]`, `kotlinc main.kt -include-runtime -d main.jar`, `java -jar main.jar`)
@LIA.lua:               @LIA.eval(`["main.lua"]`, `none`, `lua main.lua`)
@LIA.mono:              @LIA.eval(`["main.cs"]`, `mcs main.cs`, `mono main.exe`)
@LIA.nasm:              @LIA.eval(`["main.asm"]`, `nasm -felf64 main.asm && ld main.o`, `./a.out`)
@LIA.nim:               @LIA.eval(`["main.nim"]`, `nim c main.nim`, `./main`)
@LIA.nodejs:            @LIA.eval(`["main.js"]`, `none`, `node main.js`)
@LIA.ocaml:             @LIA.eval(`["main.ml"]`, `none`, `ocaml main.ml`)
@LIA.perl:              @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl main.pl`)
@LIA.perl_withShell:    @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl -d main.pl`)
@LIA.php:               @LIA.eval(`["main.php"]`, `none`, `php main.php`)
@LIA.postscript:        @LIA.eval(`["input.ps"]`, `none`, `gs -sDEVICE=png16m -r300 -o output.png input.ps`)
@LIA.prolog:            @LIA.eval(`["main.pl"]`, `none`, `swipl -s main.pl -g @0 -t halt`)
@LIA.prolog_withShell:  @LIA.eval(`["main.pl"]`, `none`, `swipl -s main.pl`)
@LIA.python:            @LIA.python3
@LIA.python_withShell:  @LIA.python3_withShell
@LIA.python2:           @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 main.pyc`)
@LIA.python2_withShell: @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 -i main.pyc`)
@LIA.python3:           @LIA.eval(`["main.py"]`, `none`, `python3 main.py`)
@LIA.python3_withShell: @LIA.eval(`["main.py"]`, `none`, `python3 -i main.py`)
@LIA.r:                 @LIA.eval(`["main.R"]`, `none`, `Rscript main.R`)
@LIA.r_withShell:       @LIA.eval(`["main.R"]`, `none`, `sh -c "cat main.R - | R --interactive"`)
@LIA.racket:            @LIA.eval(`["main.rkt"]`, `none`, `racket main.rkt`)
@LIA.ruby:              @LIA.eval(`["main.rb"]`, `none`, `ruby main.rb`)
@LIA.ruby_withShell:    @LIA.eval(`["main.rb"]`, `none`, `irb --nomultiline -r ./main.rb`)
@LIA.rust:              @LIA.eval(`["main.rs"]`, `rustc main.rs`, `./main`)
@LIA.scala:             @LIA.eval(`["@0.scala"]`, `scalac @0.scala`, `scala @0`)
@LIA.scheme:            @LIA.eval(`["main.scm"]`, `none`, `guile --no-auto-compile main.scm`)
@LIA.selectscript:      @LIA.eval(`["main.s2"]`, `none`, `S2c -x main.s2`)
@LIA.smalltalk:         @LIA.eval(`["main.st"]`, `none`, `gst main.st`)
@LIA.tcl:               @LIA.eval(`["main.tcl"]`, `none`, `tclsh main.tcl`)
@LIA.v:                 @LIA.eval(`["main.v"]`, `v main.v`, `./main`)
@LIA.v_withShell:       @LIA.eval(`["main.v"]`, `none`, `sh -c "cat main.v - | v repl"`)
@LIA.verilog:           @LIA.eval(`["main.v"]`, `iverilog -o main.vvp main.v`, `vvp main.vvp`)
@LIA.vhdl:              @LIA.eval(`["@0.vhdl"]`, `ghdl -a @0.vhdl && ghdl -e @0`, `ghdl -r @0`)
@LIA.zig:               @LIA.eval(`["main.zig"]`, `zig build-exe ./main.zig -O ReleaseSmall`, `./main`)

@LIA.dotnet
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
```
@LIA.eval(`["Program.cs","project.csproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.fsharp
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.qsharp
```xml    -project.csproj
<Project Sdk="Microsoft.Quantum.Sdk/0.28.302812">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
</Project>
```
@LIA.eval(`["Program.qs", "project.csproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.eval:  @LIA.eval_(false,`@0`,@1,@2,@3)

@LIA.evalWithDebug: @LIA.eval_(true,`@0`,@1,@2,@3)

@LIA.eval_
<script>
function random(len=16) {
    let chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let str = '';
    for (let i = 0; i < len; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return str;
}



const uid = random()
var order = @1
var files = []

var pattern = "@4".trim()

if (pattern.startsWith("\`")){
  pattern = pattern.slice(1,-1)
} else if (pattern.length === 2 && pattern[0] === "@") {
  pattern = null
}

if (order[0])
  files.push([order[0], `@'input(0)`])
if (order[1])
  files.push([order[1], `@'input(1)`])
if (order[2])
  files.push([order[2], `@'input(2)`])
if (order[3])
  files.push([order[3], `@'input(3)`])
if (order[4])
  files.push([order[4], `@'input(4)`])
if (order[5])
  files.push([order[5], `@'input(5)`])
if (order[6])
  files.push([order[6], `@'input(6)`])
if (order[7])
  files.push([order[7], `@'input(7)`])
if (order[8])
  files.push([order[8], `@'input(8)`])
if (order[9])
  files.push([order[9], `@'input(9)`])


send.handle("input", (e) => {
    CodeRunner.send(uid, {stdin: e}, send)
})
send.handle("stop",  (e) => {
    CodeRunner.send(uid, {stop: true}, send)
});


CodeRunner.handle(uid, function (msg) {
    switch (msg.service) {
        case 'data': {
            if (msg.ok) {
                CodeRunner.send(uid, {compile: @2}, send)
            }
            else {
                send.lia("LIA: stop")
            }
            break;
        }
        case 'compile': {
            if (msg.ok) {
                if (msg.message) {
                    if (msg.problems.length)
                        console.warn(msg.message);
                    else
                        console.log(msg.message);
                }

                send.lia("LIA: terminal")
                CodeRunner.send(uid, {exec: @3, filter: pattern})

                if(!@0) {
                  console.clear()
                }
            } else {
                send.lia(msg.message, msg.problems, false)
                send.lia("LIA: stop")
            }
            break;
        }
        case 'stdout': {
            if (msg.ok)
                console.stream(msg.data)
            else
                console.error(msg.data);
            break;
        }

        case 'stop': {
            if (msg.error) {
                console.error(msg.error);
            }

            if (msg.images) {
                for(let i = 0; i < msg.images.length; i++) {
                    console.html("<hr/>", msg.images[i].file)
                    console.html("<img title='" + msg.images[i].file + "' src='" + msg.images[i].data + "' onclick='window.LIA.img.click(\"" + msg.images[i].data + "\")'>")
                }
            }

            if (msg.videos) {
                for(let i = 0; i < msg.videos.length; i++) {
                    console.html("<hr/>", msg.videos[i].file)
                    console.html("<video controls style='width:100%' title='" + msg.videos[i].file + "' src='" + msg.videos[i].data + "'></video>")
                }
            }

            if (msg.files) {
                let str = "<hr/>"
                for(let i = 0; i < msg.files.length; i++) {
                    str += `<a href='data:application/octet-stream${msg.files[i].data}' download="${msg.files[i].file}">${msg.files[i].file}</a> `
                }

                console.html(str)
            }

            window.console.warn(msg)

            send.lia("LIA: stop")
            break;
        }

        default:
            console.log(msg)
            break;
    }
})


CodeRunner.send(
    uid, { "data": files }, send, true
);

"LIA: wait"
</script>
@end
-->


# CodeRunner

                         --{{0}}--
This project allows you to run a code-running server, based on Python, that
can compile and execute code and communicate via websockets. Thus, if you want
to develop some interactive online courses, this is probably a good way to
start. This README is also a self-contained LiaScript template, that defines
some basic macros, which can be used to make your Markdown code-snippets
executable.

__Try it on LiaScript:__

https://liascript.github.io/course/?https://github.com/liascript/CodeRunner

__See the project on Github:__

https://github.com/liascript/CodeRunner

                        --{{1}}--
There are three ways to use this template. The easiest way is to use the
`import` statement and the URL of the raw text-file of the master branch or any
other branch or version. But you can also copy the required functionality
directly into the header of your Markdown document, see therefor the
[last slide](#implementation). And of course, you could also clone this project
and change it, as you wish.

	                        {{1}}
1. Load the macros via

   `import: https://raw.githubusercontent.com/LiaScript/CodeRunner/master/README.md`

2. Copy the definitions into your Project

3. Clone this repository on GitHub



## `@LIA.eval`

You only have to attach the command `@LIA.eval` to your code-block or project
and pass three parameters.

1. The first, is a list of filenames, the number of sequential code-blocks
   defines the naming order.
2. Then pass the command how your code should be compiled
3. And as the last part, how to execute your code.


```` Markdown
```c
#include <stdio.h>

int main (void){
  printf ("Hello, world \n");

	return 0;
}
```
@LIA.eval(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)
````

In most cases it is sufficient to have only one file.
For this purpose we also provide shortcuts, such that the complex functionality above can be simplified with only the macro `@LIA.c`.
These shortcuts always assume one file only.

## Languages

The following overview shows you the available languages and their shortcuts.
To some languages, we also provide a shell, which allows you to interact with the code after it has been executed.
Simply add `_withShell` to the language name, e.g., `@LIA.elixir_withShell`.

### Ada : `@LIA.ada`

**Ada Language Summary:**

Ada is a structured, statically typed, imperative, and object-oriented high-level programming language, designed primarily for systems and real-time embedded applications. It is known for its strong typing, explicit concurrency, and reliability features, making it ideal for safety-critical systems. Ada was developed in the early 1980s by Jean Ichbiah under contract to the U.S. Department of Defense. One of the most commonly used Ada compilers is GNAT, and the backend here uses the GNAT-12 compiler, which ensures robust and efficient code generation.

For more detailed information, you can visit the [Wikipedia page on Ada](https://en.wikipedia.org/wiki/Ada_%28programming_language%29).

---

```ada
with Ada.Text_IO; use Ada.Text_IO;
procedure Main is
begin
   Put_Line ("Hello WORLD!");
end Main;
```
@LIA.ada

### ALGOL : `@LIA.algol`

ALGOL (Algorithmic Language) is a family of imperative, procedural, and structured programming languages that were developed in the late 1950s and early 1960s. ALGOL was designed to be a universal language for expressing algorithms and was influential in the development of modern programming languages. ALGOL 60, the most well-known version, introduced many concepts that are still used today, such as block structures, recursion, and parameter passing mechanisms. The backend here uses the ALGOL 60 compiler to compile and execute ALGOL code, ensuring compatibility with the original language specification.

For more information, you can visit the [ALGOL programming language Wikipedia page](https://en.wikipedia.org/wiki/ALGOL).

---

```algol
BEGIN
    print(("Hello, World!", new line))
END
```
@LIA.algol


### APL : `@LIA.apl`

APL (A Programming Language) is a high-level, array-oriented programming language that was developed in the 1960s by Kenneth E. Iverson. APL is known for its concise and expressive syntax, which uses a wide range of special symbols to represent mathematical functions and operations. It is particularly well-suited for numerical and array processing tasks, making it popular in scientific computing, data analysis, and financial modeling. The backend here uses the Dyalog APL interpreter, which provides a powerful environment for developing and executing APL code.

For more information, you can visit the [APL programming language Wikipedia page](https://en.wikipedia.org/wiki/APL_%28programming_language%29).

---

```apl
⎕←'abcd' ∘.= 'cabbage'
```
@LIA.apl


### Assembly (nasm) : `@LIA.nasm`

Assembly language is a low-level programming language that provides direct control over hardware through symbolic representation of machine code instructions. Each instruction in an assembly language corresponds closely to a machine code instruction supported by the architecture's CPU. Assembly language is often used in system programming, particularly for writing operating systems, device drivers, and embedded systems, where precise control of the hardware is essential. In the backend, the NASM (Netwide Assembler) compiler is used, which is a popular assembler for x86 architecture, known for its portability and flexibility.

For more information, you can visit the [Assembly language Wikipedia page](https://en.wikipedia.org/wiki/Assembly_language).

---

```asm
; ----------------------------------------------------------------------------------------
; Writes "Hello, World" to the console using only system calls. Runs on 64-bit Linux only.
; To assemble and run:
;
;     nasm -felf64 main.asm && ld main.o && ./a.out
; ----------------------------------------------------------------------------------------

          global    _start

          section   .text
_start:   mov       rax, 1                  ; system call for write
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rsi, message            ; address of string to output
          mov       rdx, 13                 ; number of bytes
          syscall                           ; invoke operating system to do the write
          mov       rax, 60                 ; system call for exit
          xor       rdi, rdi                ; exit code 0
          syscall                           ; invoke operating system to exit

          section   .data
message:  db        "Hello, World", 10      ; note the newline at the end
```
@LIA.nasm

### AWK : `@LIA.awk`

AWK is a versatile and powerful programming language that is primarily used for text processing and data extraction. It was developed in the 1970s by Alfred Aho, Peter Weinberger, and Brian Kernighan, and its name is derived from their initials. AWK provides a rich set of features for pattern matching, text manipulation, and data processing, making it a popular choice for working with structured data files, log files, and reports. The backend here uses the GNU AWK interpreter, which is a free and open-source implementation of the AWK language, providing a flexible and efficient environment for writing AWK scripts.

For more information, you can visit the [AWK programming language Wikipedia page](https://en.wikipedia.org/wiki/AWK).

---

```awk
BEGIN {
    print "Hello, World!"
}
```
@LIA.awk

### Basic (bwbasic) : `@LIA.basic`

BASIC (Beginner's All-purpose Symbolic Instruction Code) is a high-level programming language that was developed in the 1960s to provide an easy-to-learn and easy-to-use language for beginners. BASIC is known for its simplicity and readability, making it an ideal language for teaching programming concepts to novices. The backend here uses the BWBASIC interpreter, which is a modern implementation of the original BASIC language, providing a simple and interactive environment for writing and executing BASIC code.

For more information, you can visit the [BASIC programming language Wikipedia page](https://en.wikipedia.org/wiki/BASIC).

---

```basic
10 PRINT "Hello, World!"
20 SYSTEM
```
@LIA.basic

... or stay in the shell, by using `END`

```basic
10 PRINT "Hello, World!"
20 END
```
@LIA.basic

### C : `@LIA.c`

C is a general-purpose, procedural programming language that was developed in the early 1970s by Dennis Ritchie at Bell Labs. It has become one of the most widely used programming languages of all time due to its efficiency, flexibility, and closeness to system hardware, making it ideal for operating systems, system software, and embedded systems. C provides low-level access to memory and allows for fine-grained control over the execution of programs. The language is also known for its simplicity and powerful set of operators. The backend here uses the GCC (GNU Compiler Collection) for compiling C code, ensuring highly optimized and portable executables.

For more information, you can visit the [C programming language Wikipedia page](https://en.wikipedia.org/wiki/C_%28programming_language%29).

---

```c
#include <stdio.h>

int main (void){
	int i = 0;
	int max = 0;

	printf("How many hellos: ");
	scanf("%d",&max);

  for(i=0; i<max; i++)
    printf ("Hello, world %d!\n", i);

	return 0;
}
```
@LIA.c

### C++ : `@LIA.cpp`

C++ is a general-purpose programming language that was developed as an extension of the C language by Bjarne Stroustrup in the early 1980s. It supports both procedural and object-oriented programming paradigms, allowing for flexible and powerful software development. C++ introduces features like classes, inheritance, polymorphism, templates, and exception handling, which provide greater abstraction and code reuse compared to C. It is widely used for system/software development, game development, real-time simulation, and performance-critical applications. The backend here uses the GCC (GNU Compiler Collection) for compiling C++ code, ensuring high performance and compatibility across different platforms.

For more information, you can visit the [C++ programming language Wikipedia page](https://en.wikipedia.org/wiki/C%2B%2B).

---

```cpp
#include <iostream>
using namespace std;

int main (){
	int i = 0;
	int max = 0;

	cout << "How many hellos: ";
	cin >> max;

  for(i=0; i<max; i++)
    cout << "Hello, world " << i << endl;

	return 0;
}
```
@LIA.cpp

### C# Mono : `@LIA.mono`

C# (C-Sharp) is a modern, object-oriented programming language developed by Microsoft as part of its .NET initiative, first released in 2000. It is designed to be simple, efficient, and easy to use, combining the power of C++ with the ease of use of higher-level languages like Java. C# is widely used for developing Windows applications, web services, and enterprise software, and it integrates seamlessly with the .NET framework, providing a rich standard library and advanced features like garbage collection, type safety, and versioning. The backend here uses the Mono compiler, an open-source implementation of Microsoft's .NET framework, to compile C# code, ensuring cross-platform compatibility and robust execution.

For more information, you can visit the [C# programming language Wikipedia page](https://en.wikipedia.org/wiki/C_Sharp_%28programming_language%29).

---

```csharp
/*
 * C# Program to Check whether the Entered Number is Even or Odd
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace check1
{
    class Program
    {
        static void Main(string[] args)
        {
            int i;
            Console.Write("Enter a Number : ");
            i = int.Parse(Console.ReadLine());
            if (i % 2 == 0)
            {
                Console.Write("Entered Number is an Even Number");
            }
            else
            {
                Console.Write("Entered Number is an Odd Number");
            }
        }
    }
}
```
@LIA.mono

### C# DotNet : `@LIA.dotnet` 

C# (C-Sharp) is a modern, object-oriented programming language developed by Microsoft as part of its .NET initiative, first released in 2000. It is designed to be simple, powerful, and versatile, combining the high performance of C++ with the ease of use found in higher-level languages like Java. C# is extensively used for developing Windows applications, web services, and enterprise software. It integrates deeply with the .NET framework, providing a vast standard library, support for modern programming paradigms, and features like garbage collection, type safety, and language interoperability. The backend here uses the .NET compiler to compile C# code, ensuring optimized performance and seamless integration with the .NET ecosystem.

For more information, you can visit the [C# programming language Wikipedia page](https://en.wikipedia.org/wiki/C_Sharp_%28programming_language%28).

---

The macro `@LIA.dotnet` already includes a default project file.

```csharp
// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");
```
@LIA.dotnet

---

But you are free to add your own project file, if you want to.

```csharp
// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");
```
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
```
@LIA.eval(`["Program.cs", "project.csproj"]`, `dotnet build -nologo`, `dotnet run`)

---

### Clojure : `@LIA.clojure`

**Clojure Language Summary:**

Clojure is a modern, functional, and dynamically-typed programming language that runs on the Java Virtual Machine (JVM). It was created by Rich Hickey and first released in 2007. Clojure emphasizes immutability, concurrency, and simplicity, making it ideal for building robust and scalable applications. It combines the best features of Lisp—such as code-as-data (homoiconicity) and a powerful macro system—with seamless Java interoperability, allowing developers to use existing Java libraries and tools. The backend here uses the Clojure compiler to execute Clojure code, ensuring efficient performance on the JVM.

For more information, you can visit the [Clojure programming language Wikipedia page](https://en.wikipedia.org/wiki/Clojure).

---

``` clojure
(ns clojure.examples.hello
   (:gen-class))
(defn hello-world []
   (println "Hello World"))
(hello-world)
```
@LIA.clojure

----

Additionally, you can also use the `@LIA.clojure_withShell` macro, which will start a REPL after the code has been executed.

``` clojure
(ns clojure.examples.hello
   (:gen-class))
(defn hello-world []
   (println "Hello World"))
(hello-world)
```
@LIA.clojure_withShell


### COBOL : `@LIA.cobol`

COBOL (Common Business-Oriented Language) is a high-level programming language designed for business data processing. It was developed in the late 1950s and early 1960s by a committee of computer professionals from private industry, universities, and government agencies. COBOL is known for its readability, self-documenting code, and English-like syntax, making it easy to understand and maintain. It is widely used in legacy systems, financial institutions, and government agencies for processing large volumes of data. The backend here uses the GnuCOBOL compiler to compile COBOL code, ensuring compatibility and efficient execution.

For more information, you can visit the [COBOL programming language Wikipedia page](https://en.wikipedia.org/wiki/COBOL).


```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO-WORLD.
       PROCEDURE DIVISION.
           DISPLAY 'Hello, world'.
           STOP RUN.
```
@LIA.cobol

### Coq : `@LIA.coq`

Coq is an interactive theorem prover and functional programming language developed by the French Institute for Research in Computer Science and Automation (INRIA). It is designed for formal verification of mathematical proofs and software programs, allowing developers to write and verify complex mathematical statements and algorithms. Coq is based on the Calculus of Inductive Constructions (CIC), a powerful type theory that supports dependent types, higher-order logic, and formal reasoning. The backend here uses the Coq compiler to execute Coq code, ensuring correctness and reliability of the proofs and programs.

For more information, you can visit the [Coq programming language Wikipedia page](https://en.wikipedia.org/wiki/Coq).

---

```coq
Require Import ZArith.
Open Scope Z_scope.
Goal forall a b c:Z,
    (a + b + c) ^ 2 =
     a * a + b ^ 2 + c * c + 2 * a * b + 2 * a * c + 2 * b * c.
  intros; ring.
Qed.
```
@LIA.coq

### D : `@LIA.d`

D is a systems programming language with C-like syntax and static typing. It combines the power and performance of C and C++ with the safety and expressiveness of modern programming languages like Rust and Swift. D is designed for writing efficient, maintainable, and scalable software, making it ideal for system programming, game development, and high-performance applications. The backend here uses the DMD (Digital Mars D) compiler to compile D code, ensuring fast and reliable execution.

For more information, you can visit the [D programming language Wikipedia page](https://en.wikipedia.org/wiki/D_%28programming_language%29).

---

```d
import std.stdio;

void main()
{
    writeln("Hello, World!");
}
```
@LIA.d

### Delphi : `@LIA.delphi`

Delphi is an integrated development environment (IDE) and object-oriented programming language based on the Object Pascal language. It was developed by Borland in the mid-1990s and is known for its rapid application development (RAD) capabilities, particularly for Windows applications. Delphi provides a visual programming environment, allowing developers to design user interfaces using drag-and-drop components. The backend here uses the Free Pascal compiler to compile Delphi code, ensuring compatibility with modern Pascal standards.

For more information, you can visit the [Delphi programming language Wikipedia page](https://en.wikipedia.org/wiki/Delphi_%28programming_language%29).

---

``` delphi
program example001;
uses
  SysUtils;
var
  i      : Integer;
  Zahl   : Real;
  Antwort: Char;
begin
  WriteLn('Programmbeispiel Kontrollstrukturen');
  WriteLn;
  repeat                  // nicht abweisende Schleife
    Write('Bitte geben Sie eine Zahl ein: ');
    ReadLn(Zahl);
    if Zahl <> 0 then     // einseitige Auswahl
      Zahl := 1 / Zahl;
    for i := 1 to 10 do   // Zählschleife
      Zahl := Zahl * 2;
    while Zahl > 1 do     // abweisende Schleife
      Zahl := Zahl / 2;
    i := Round(Zahl) * 100;
    case i of             // Fallunterscheidung
      1: Zahl := Zahl * 2;
      2: Zahl := Zahl * 4;
      4: Zahl := Zahl * 8
    else
      Zahl := Zahl * 10
    end;
    if Zahl <> 0 then     // zweiseitige Auswahl
      WriteLn(Format('Das Ergebnis lautet %.2f', [Zahl]))
    else
      Writeln('Leider ergibt sich der Wert von 0.');
    Write('Noch eine Berechnung (J/N)? ');
    ReadLn(Antwort)
  until UpCase(Antwort) = 'N'
end.
```  
@LIA.eval(`["main.pas"]`, `fpc main.pas`, `./main`)

### Elixir : `@LIA.elixir`

Elixir is a dynamic, functional programming language designed for building scalable and maintainable applications. It was created by José Valim and first released in 2011. Elixir runs on the Erlang Virtual Machine (BEAM), which provides excellent support for concurrency, fault tolerance, and distributed systems. Elixir leverages the strengths of Erlang while offering a more modern syntax and powerful metaprogramming capabilities. It is widely used for web development, embedded systems, and applications requiring high reliability. The backend here uses the Elixir compiler to execute Elixir code, ensuring robust and efficient performance on the BEAM platform.

For more information, you can visit the [Elixir programming language Wikipedia page](https://en.wikipedia.org/wiki/Elixir_%28programming_language%29).

---

```elixir
IO.puts "Hello World"
```
@LIA.elixir

---

Additionally, you can also use the `@LIA.elixir_withShell` macro, which will start an IEx shell after the code has been executed.

```elixir
IO.puts "Hello World"
```
@LIA.elixir_withShell


### Erlang : `@LIA.erlang`

Erlang is a functional programming language designed for building concurrent, distributed, and fault-tolerant systems. It was developed by Ericsson in the late 1980s and is known for its lightweight processes, message-passing concurrency model, and hot code swapping capabilities. Erlang is particularly well-suited for telecommunications, real-time systems, and applications requiring high availability. The backend here uses the Erlang compiler to execute Erlang code, ensuring efficient performance and reliability.

For more information, you can visit the [Erlang programming language Wikipedia page](https://en.wikipedia.org/wiki/Erlang_%28programming_language%29).

---

```erlang
-module(hello).
-export([hello/0]).
hello() ->
    io:format("Hello, World!~n").
```
@LIA.erlang

---

Additionally, you can also use the `@LIA.erlang_withShell` macro, which will start an Erlang shell after the code has been executed.

```erlang
-module(hello).
-export([hello/0]).
hello() ->
    io:format("Hello, World!~n").
```
@LIA.erlang_withShell


### F# : `@LIA.fsharp`

**F# Language Summary:**

F# is a functional-first programming language that runs on the .NET platform. It was developed by Microsoft Research and first released in 2005. F# is known for its strong support for functional programming paradigms, but it also seamlessly integrates with object-oriented and imperative programming, making it a versatile language for a wide range of applications. It is particularly well-suited for tasks involving data analysis, scientific computing, and financial modeling, thanks to its concise syntax, powerful type system, and efficient performance. The backend here uses the .NET compiler to compile F# code, ensuring compatibility and high performance within the .NET ecosystem.

For more information, you can visit the [F# programming language Wikipedia page](https://en.wikipedia.org/wiki/F_Sharp_%28programming_language%29).

---

The project file is already included in the macro `@LIA.fsharp`.

```fsharp    +Program.fs
// See https://aka.ms/new-console-template for more information
printfn "Hello from F#"
```
@LIA.fsharp

---

But you are free to add your own project file manually, if you want to.

```fsharp    +Program.fs
// See https://aka.ms/new-console-template for more information
printfn "Hello from F#"
```
```xml       -project.fsporj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)


### Forth : `@LIA.forth`

Forth is a stack-based, extensible, and interactive programming language that was developed in the late 1960s by Charles H. Moore. It is known for its simplicity, flexibility, and efficiency, making it ideal for embedded systems, real-time applications, and low-level programming tasks. Forth uses a postfix notation, where operations are performed by pushing and popping values on a data stack. It provides direct access to memory and hardware, allowing for fine-grained control over system resources. The backend here uses the Gforth interpreter to execute Forth code, ensuring fast and reliable execution.

For more information, you can visit the [Forth programming language Wikipedia page](https://en.wikipedia.org/wiki/Forth_%28programming_language%29).

---

```forth
: hello ." Hello, world!" cr ;
hello
```
@LIA.forth

### Fortran : `@LIA.fortran`

Fortran (Formula Translation) is a high-level programming language developed by IBM in the 1950s for scientific and engineering applications. It is known for its efficiency, numerical accuracy, and extensive library of mathematical functions, making it ideal for numerical computations, simulations, and data analysis. Fortran has evolved over the years, with the latest standard being Fortran 2018, which includes modern features like coarrays, improved parallelism, and interoperability with C. The backend here uses the GNU Fortran compiler (gfortran) to compile Fortran code, ensuring high performance and compatibility with modern Fortran standards.

For more information, you can visit the [Fortran programming language Wikipedia page](https://en.wikipedia.org/wiki/Fortran).

---

```fortran
program hello
  print *, "Hello, world!"
end program hello
```
@LIA.fortran

### Groovy : `@LIA.groovy`

Groovy is a dynamic, object-oriented programming language that runs on the Java Virtual Machine (JVM). It was created by James Strachan and first released in 2003. Groovy is known for its simplicity, flexibility, and seamless integration with Java, allowing developers to write concise and expressive code. It supports features like closures, dynamic typing, and metaprogramming, making it ideal for scripting, web development, and automation tasks. The backend here uses the Groovy compiler to execute Groovy code, ensuring compatibility with the JVM and access to the Java ecosystem.

For more information, you can visit the [Groovy programming language Wikipedia page](https://en.wikipedia.org/wiki/Apache_Groovy).

---

```groovy
println "Hello, world!"
```
@LIA.groovy


### GO : `@LIA.go`

Go, also known as Golang, is a statically typed, compiled programming language designed by Google engineers and first released in 2009. It is known for its simplicity, efficiency, and strong support for concurrent programming. Go combines the performance and safety of a compiled language like C with the ease of use and productivity features of dynamically typed languages. It is particularly well-suited for building large-scale, distributed systems, cloud services, and other performance-critical applications. The backend here uses the `golang-go` compiler to compile Go code, ensuring fast and reliable execution.

For more information, you can visit the [Go programming language Wikipedia page](https://en.wikipedia.org/wiki/Go_%28programming_language%29).

---

``` go
package main

import "fmt"

func main() {
  fmt.Println("hello world")
}
```
@LIA.go

### Haskell : `@LIA.haskell`

Haskell is a purely functional programming language known for its strong static type system, immutability, and lazy evaluation. It was developed in the late 1980s as a standardized open-source language to serve as a foundation for research and teaching in functional programming. Haskell is ideal for applications that require robust correctness, such as financial systems, data analysis, and concurrent programming. It supports powerful abstractions like monads and higher-order functions, making it highly expressive and concise. The backend here uses the GHC (Glasgow Haskell Compiler) to compile Haskell code, ensuring optimized performance and advanced features.

For more information, you can visit the [Haskell programming language Wikipedia page](https://en.wikipedia.org/wiki/Haskell_%28programming_language%29).

---

``` haskell
main = putStrLn "hello world"
```
@LIA.haskell

---

Additionally, you can also use the `@LIA.haskell_withShell` macro, which will start a GHCi shell after the code has been executed.

``` haskell
main = putStrLn "hello world"
```
@LIA.haskell_withShell

### Haxe : `@LIA.haxe`

Haxe is a high-level, cross-platform programming language that was developed by Nicolas Cannasse in 2005. It is known for its versatility, performance, and ease of use, making it ideal for building web applications, games, and mobile apps. Haxe is a strongly typed language that compiles to multiple target platforms, including JavaScript, C++, and Java, allowing developers to write code once and deploy it across different environments. The backend here uses the Haxe compiler to execute Haxe code, ensuring compatibility with various platforms and efficient performance.

For more information, you can visit the [Haxe programming language Wikipedia page](https://en.wikipedia.org/wiki/Haxe).

---

``` haxe
class Main {
    static function main() {
        trace("Hello, World!");
    }
}
```
@LIA.haxe


### Inform : `@LIA.inform`

This program is a compiler of Infocom format (also called "Z-machine") text adventure games, written in Inform 6. The Z-machine was developed by Infocom to run its text adventures, and it has since been used by other interactive fiction authors. The Inform 6 compiler is a powerful tool for creating interactive fiction games, providing a high-level language for writing game logic and a virtual machine for executing the compiled games. The backend here uses the Inform 6 compiler to compile Inform code, ensuring compatibility with the Z-machine and the ability to run text adventure games.

For more information, you can visit the [Inform programming language Wikipedia page](https://en.wikipedia.org/wiki/Inform).
---

``` inform
Constant Story "Hello Deductible";
Constant Headline "^An Interactive Example^";

Include "Parser";
Include "VerbLib";

[ Initialise;
    location = Living_Room;
    "Hello World";
];

Object Kitchen "Kitchen";
Object Front_Door "Front Door";

Object Living_Room "Living Room"
    with
        description "A comfortably furnished living room.",
        n_to Kitchen,
        s_to Front_Door,
    has light;

Object -> Salesman "insurance salesman"
    with
        name 'insurance' 'salesman' 'man',
        description "An insurance salesman in a tacky polyester
              suit.  He seems eager to speak to you.",
        before [;
            Listen:
                move Insurance_Paperwork to player;
                "The salesman bores you with a discussion
                 of life insurance policies.  From his
                 briefcase he pulls some paperwork which he
                 hands to you.";
        ],
    has animate;

Object -> -> Briefcase "briefcase"
    with
        name 'briefcase' 'case',
        description "A slightly worn, black briefcase.",
    has container;

Object -> -> -> Insurance_Paperwork "insurance paperwork"
    with
        name 'paperwork' 'papers' 'insurance' 'documents' 'forms',
        description "Page after page of small legalese.";

Include "Grammar";
```
@LIA.inform

### IO : `@LIA.io`

Io is a prototype-based, object-oriented programming language that was developed by Steve Dekorte in the early 2000s. It is known for its simplicity, minimalism, and powerful message-passing model, making it ideal for building dynamic and interactive applications. Io is inspired by Smalltalk, Self, and Lisp, and it provides a flexible and extensible environment for creating domain-specific languages and frameworks. The backend here uses the Io interpreter to execute Io code, ensuring fast and efficient execution.

For more information, you can visit the [Io programming language Wikipedia page](https://en.wikipedia.org/wiki/Io_%28programming_language%29).

---

``` io
"Hello, world!" println
```
@LIA.io

As an alternative, you can also run it within an interactive REPL shell.

``` io
"Hello, world!" println
```
@LIA.io_withShell

### Java : `@LIA.java`

Java is a widely-used, class-based, object-oriented programming language that was developed by Sun Microsystems (now owned by Oracle) and released in 1995. It is designed to be platform-independent, meaning that compiled Java code can run on any platform that supports the Java Virtual Machine (JVM). Java is known for its portability, scalability, and strong memory management features, making it ideal for building large-scale enterprise applications, Android apps, and web services. The language's syntax is similar to C++, but it simplifies many complex features, making it easier to learn and use. The backend here uses `jdk-21_linux-x64_bin`, the latest version of the Java Development Kit (JDK), to compile and execute Java code, ensuring cutting-edge performance and compatibility with modern Java features.

For more information, you can visit the [Java programming language Wikipedia page](https://en.wikipedia.org/wiki/Java_%28programming_language%29).

---

The short-cut for java requires a special parameter, which is the name of the class, such that this can be substituted within filenames and commands.

``` java
import java.io.*;
class Demo {
public static void main(String args[])
throws IOException
{
  // create a BufferedReader using System.in
  BufferedReader obj = new BufferedReader(new InputStreamReader(System.in));
   String str;

 System.out.println("Enter lines of text.");
 System.out.println("Enter 'stop' to quit.");
   do {

    str = obj.readLine();
    System.err.println(str);
  }   while(!str.equals("stop"));
}
}
```
@LIA.java(Demo)

---

But, you can also use the `@LIA.eval` macro, which allows you to define all settings manually.

``` java
import java.io.*;
class Demo {
public static void main(String args[])
throws IOException
{
  // create a BufferedReader using System.in
  BufferedReader obj = new BufferedReader(new InputStreamReader(System.in));
   String str;

 System.out.println("Enter lines of text.");
 System.out.println("Enter 'stop' to quit.");
   do {

    str = obj.readLine();
    System.err.println(str);
  }   while(!str.equals("stop"));
}
}
```
@LIA.eval(`["Demo.java"]`, `javac Demo.java`, `java Demo`)

### Julia : `@LIA.julia`

Julia is a high-level, high-performance programming language designed for technical and scientific computing. It was first released in 2012 and has gained popularity for its ability to handle numerical and computational tasks efficiently, combining the speed of languages like C and Fortran with the ease of use of Python and R. Julia supports multiple programming paradigms, including functional, object-oriented, and parallel programming, and it is particularly well-suited for data analysis, machine learning, and simulations. The backend here uses Julia 1.9.3 to execute Julia code, ensuring optimal performance and access to the latest language features.

For more information, you can visit the [Julia programming language Wikipedia page](https://en.wikipedia.org/wiki/Julia_%28programming_language%29).

---

```julia
# function to calculate the volume of a sphere
function sphere_vol(r)
    # julia allows Unicode names (in UTF-8 encoding)
    # so either "pi" or the symbol π can be used
    return 4/3*pi*r^3
end

# functions can also be defined more succinctly
quadratic(a, sqr_term, b) = (-b + sqr_term) / 2a

# calculates x for 0 = a*x^2+b*x+c, arguments types can be defined in function definitions
function quadratic2(a::Float64, b::Float64, c::Float64)
    # unlike other languages 2a is equivalent to 2*a
    # a^2 is used instead of a**2 or pow(a,2)
    sqr_term = sqrt(b^2-4a*c)
    r1 = quadratic(a, sqr_term, b)
    r2 = quadratic(a, -sqr_term, b)
    # multiple values can be returned from a function using tuples
    # if the return keyword is omitted, the last term is returned
    r1, r2
end

vol = sphere_vol(3)
# @printf allows number formatting but does not automatically append the \n to statements, see below
using Printf
@printf "volume = %0.3f\n" vol 
#> volume = 113.097

quad1, quad2 = quadratic2(2.0, -2.0, -12.0)
println("result 1: ", quad1)
#> result 1: 3.0
println("result 2: ", quad2)
#> result 2: -2.0
```
@LIA.julia

---

Additionally, you can also use the `@LIA.julia_withShell` macro, which will start a Julia shell after the code has been executed.

```julia
# function to calculate the volume of a sphere
function sphere_vol(r)
    # julia allows Unicode names (in UTF-8 encoding)
    # so either "pi" or the symbol π can be used
    return 4/3*pi*r^3
end

# functions can also be defined more succinctly
quadratic(a, sqr_term, b) = (-b + sqr_term) / 2a

# calculates x for 0 = a*x^2+b*x+c, arguments types can be defined in function definitions
function quadratic2(a::Float64, b::Float64, c::Float64)
    # unlike other languages 2a is equivalent to 2*a
    # a^2 is used instead of a**2 or pow(a,2)
    sqr_term = sqrt(b^2-4a*c)
    r1 = quadratic(a, sqr_term, b)
    r2 = quadratic(a, -sqr_term, b)
    # multiple values can be returned from a function using tuples
    # if the return keyword is omitted, the last term is returned
    r1, r2
end

vol = sphere_vol(3)
# @printf allows number formatting but does not automatically append the \n to statements, see below
using Printf
@printf "volume = %0.3f\n" vol 
#> volume = 113.097

quad1, quad2 = quadratic2(2.0, -2.0, -12.0)
println("result 1: ", quad1)
#> result 1: 3.0
println("result 2: ", quad2)
#> result 2: -2.0
```
@LIA.julia_withShell

### Kotlin : `@LIA.kotlin`

Kotlin is a modern, statically typed programming language developed by JetBrains in 2011. It is designed to be fully interoperable with Java and runs on the Java Virtual Machine (JVM). Kotlin combines object-oriented and functional programming features, making it a versatile language for building Android apps, web services, and enterprise applications. It is known for its conciseness, safety features, and expressive syntax, which reduce boilerplate code and improve developer productivity. The backend here uses the Kotlin compiler to compile Kotlin code, ensuring compatibility with the JVM and access to the Java ecosystem.

For more information, you can visit the [Kotlin programming language Wikipedia page](https://en.wikipedia.org/wiki/Kotlin_%28programming_language%29).

---

```kotlin
fun main() {
    println("Hello, World!")
}
```
@LIA.kotlin

### Lua : `@LIA.lua`

Lua is a lightweight, high-level programming language designed for embedded systems, scripting, and game development. It was developed in the early 1990s by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, and Waldemar Celes at the Pontifical Catholic University of Rio de Janeiro. Lua is known for its simplicity, efficiency, and extensibility, making it ideal for integrating with other languages and platforms. It provides a powerful set of features, including first-class functions, coroutines, and metatables, which enable developers to build flexible and scalable applications. The backend here uses the Lua interpreter to execute Lua code, ensuring fast and reliable execution.

For more information, you can visit the [Lua programming language Wikipedia page](https://en.wikipedia.org/wiki/Lua_%28programming_language%29).

---

```lua
print("Hello, world!")
```
@LIA.lua

### Modula 2 : `@LIA.modula2`

Modula-2 is a procedural programming language developed by Niklaus Wirth in the late 1970s as a successor to Pascal. It is known for its simplicity, strong typing, and modular programming features, making it ideal for teaching programming concepts and developing reliable software. Modula-2 introduced many concepts that are now common in modern programming languages, such as modules, data abstraction, and exception handling. The backend here uses the GNU Modula-2 compiler to compile Modula-2 code, ensuring compatibility and efficient execution.

For more information, you can visit the [Modula-2 programming language Wikipedia page](https://en.wikipedia.org/wiki/Modula-2).

---

```modula2
MODULE hello ;

FROM StrIO IMPORT WriteString, WriteLn ;

BEGIN
   WriteString ('hello world') ; WriteLn
END hello.
```
@LIA.eval(`["hello.mod"]`, `gm2 hello.mod`, `./a.out`)

### Nim : `@LIA.nim`

Nim is a statically typed, compiled programming language that combines the performance of C with the expressiveness of modern languages like Python. First released in 2008, Nim is known for its simplicity, efficiency, and flexibility, making it suitable for systems programming, web development, and scientific computing. Nim features a powerful metaprogramming system, automatic memory management, and a syntax that is easy to read and write. It compiles to C, C++, and JavaScript, enabling cross-platform development with high performance. The backend here uses the Nim compiler to execute Nim code, ensuring efficient and optimized output.

For more information, you can visit the [Nim programming language Wikipedia page](https://en.wikipedia.org/wiki/Nim_%28programming_language%29).

---

```nim
echo "Hello World"
```
@LIA.nim

### Node.js : `@LIA.nodejs`

Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. It allows you to run JavaScript code outside of a web browser, enabling server-side scripting, command-line tools, and automation tasks. Node.js provides a rich set of libraries and frameworks for building web applications, APIs, and microservices. It is known for its event-driven, non-blocking I/O model, which allows for high concurrency and scalability. The backend here uses the Node.js runtime to execute JavaScript code, ensuring compatibility with the latest ECMAScript features and access to the Node.js ecosystem.

For more information, you can visit the [Node.js Wikipedia page](https://en.wikipedia.org/wiki/Node.js).

---

```javascript
console.log("Hello, World!");
```
@LIA.nodejs


### Objective-C : `@LIA.objectivec`

Objective-C is a general-purpose, object-oriented programming language that was developed by Brad Cox and Tom Love in the early 1980s. It is known for its dynamic runtime, message-passing syntax, and close integration with the C programming language. Objective-C was the primary language used for developing macOS and iOS applications before the introduction of Swift. It provides a rich set of features for building graphical user interfaces, handling events, and managing memory, making it ideal for developing desktop and mobile applications. The backend here uses the Clang compiler to compile Objective-C code, ensuring compatibility and efficient execution.

For more information, you can visit the [Objective-C programming language Wikipedia page](https://en.wikipedia.org/wiki/Objective-C).

---

```objectivec
// 'Hello World' Program in Objective-C
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog (@"Hello, World!");
    [pool drain];
    return 0;
}
```
@LIA.eval(`["main.m"]`, `gobjc main.m`, `./main`)

### OCaml : `@LIA.ocaml`

OCaml is a statically typed, functional programming language that was developed in the late 1990s as an extension of the Caml language. It is known for its strong type system, type inference, and support for functional, imperative, and object-oriented programming paradigms. OCaml is widely used in academia and industry for developing compilers, interpreters, theorem provers, and other applications that require high reliability and performance. The backend here uses the OCaml compiler to execute OCaml code, ensuring efficient and optimized execution.

For more information, you can visit the [OCaml programming language Wikipedia page](https://en.wikipedia.org/wiki/OCaml).

---

```ocaml
print_string "Hello, world!\n";;
```
@LIA.ocaml

### Octave : `@LIA.octave`

Octave is a high-level, interpreted programming language primarily used for numerical computations and data analysis. It is compatible with MATLAB and provides a similar syntax and functionality, making it a popular choice for scientific computing, machine learning, and signal processing. Octave supports matrix operations, plotting, and algorithm development, allowing users to prototype and test complex mathematical models efficiently. The backend here uses the Octave interpreter to execute Octave code, ensuring compatibility with MATLAB scripts and toolboxes.

For more information, you can visit the [Octave programming language Wikipedia page](https://en.wikipedia.org/wiki/GNU_Octave).

---

```octave
disp("Hello, world!")
```
@LIA.eval(`["main.m"]`, `none`, `octave --no-window-system main.m`)

### Pascal : `@LIA.pascal`

Pascal is a high-level, procedural programming language developed by Niklaus Wirth in the late 1960s. It was designed to encourage good programming practices and provide a structured approach to software development. Pascal is known for its readability, simplicity, and strong typing, making it ideal for teaching programming concepts and developing reliable software. It introduced many features that are now common in modern programming languages, such as block structures, data structures, and modular programming. The backend here uses the Free Pascal compiler to compile Pascal code, ensuring compatibility and efficient execution.

For more information, you can visit the [Pascal programming language Wikipedia page](https://en.wikipedia.org/wiki/Pascal_%28programming_language%29).

---

```pascal
program HelloWorld;
begin
  writeln('Hello, world!');
end.
```
@LIA.eval(`["main.pas"]`, `fpc main.pas`, `./main`)

### Perl : `@LIA.perl`

Perl is a high-level, dynamic programming language known for its versatility and powerful text-processing capabilities. Originally developed by Larry Wall in 1987, Perl has evolved to become a popular choice for system administration, web development, and network programming. It is especially strong in string manipulation, regular expressions, and file handling, making it ideal for tasks involving data extraction, reporting, and automation. Perl's flexible syntax allows for rapid development and prototyping. The backend here uses the Perl interpreter to execute Perl scripts, ensuring compatibility and efficient performance.

For more information, you can visit the [Perl programming language Wikipedia page](https://en.wikipedia.org/wiki/Perl).

---

```perl
print "Enter your name: ";
$name=<STDIN>;
print "Hello, ${name} ... you will soon be a Perl addict!\n";
```
@LIA.perl

---

Additionally, you can also use the `@LIA.perl_withShell` macro, which will start a Perl shell after the code has been executed.

```perl
sub greet {
  my $name = shift;
  print "Hello, $name!\n";
}

my $x = 42;
```
@LIA.perl_withShell

### PHP : `@LIA.php`

PHP is a server-side scripting language designed for web development and general-purpose programming. It was created by Rasmus Lerdorf in 1994 and has since become one of the most widely used languages for building dynamic websites and web applications. PHP is known for its simplicity, flexibility, and extensive library of functions, making it easy to integrate with databases, web servers, and other technologies. It supports object-oriented programming, procedural programming, and functional programming paradigms. The backend here uses the PHP interpreter to execute PHP code, ensuring compatibility and efficient execution.

For more information, you can visit the [PHP programming language Wikipedia page](https://en.wikipedia.org/wiki/PHP).

---

```php
<?php
echo "Hello, world!";
?>
```
@LIA.php

### PostScript : `@LIA.postscript`

PostScript is a page description language developed by Adobe Systems in the early 1980s. It is used primarily in the printing and graphics industries to describe the layout and appearance of documents, images, and other visual content. PostScript is known for its flexibility, scalability, and device independence, making it ideal for generating high-quality output on a wide range of printers and displays. It uses a stack-based programming model, where operations are performed by pushing and popping values on a data stack. The backend here uses the Ghostscript interpreter to execute PostScript code, ensuring compatibility and efficient rendering.

For more information, you can visit the [PostScript programming language Wikipedia page](https://en.wikipedia.org/wiki/PostScript).

---

```postscript
%!PS
<< /PageSize [420 100] >> setpagedevice  % Set page size to A5
/Courier             % name the desired font
20 selectfont        % choose the size in points and establish 
                     % the font as the current one
 72 50 moveto        % position the current point at 
                     % coordinates 72, 500 (the origin is at the 
                     % lower-left corner of the page)
(Hello world!) show  % paint the text in parentheses
showpage             % print all on the page
```
@LIA.postscript

### Prolog : `@LIA.prolog`

Prolog is a logic programming language that was developed in the early 1970s by Alain Colmerauer and Robert Kowalski. It is based on formal logic and provides a declarative approach to problem-solving, where programs are defined as sets of logical rules and facts. Prolog is particularly well-suited for tasks involving symbolic reasoning, artificial intelligence, and natural language processing. It is known for its pattern matching and backtracking capabilities, which allow for efficient search and inference. The backend here uses the SWI-Prolog interpreter to execute Prolog code, ensuring compatibility and efficient execution.

For more information, you can visit the [Prolog programming language Wikipedia page](https://en.wikipedia.org/wiki/Prolog).

---

``` prolog
likes(mary, chocolate).
likes(mary, wine).
likes(john, wine).
likes(john, mary).

% Define the query rule to find pairs X and Y where john likes X and X likes Y
query :-
    likes(john, X),
    likes(X, Y),
    format('X = ~w, Y = ~w~n', [X, Y]).
```
@LIA.prolog(query)

---

Additionally, you can also use the `@LIA.prolog_withShell` macro, which will start a Prolog shell after the code has been executed.

``` prolog
likes(mary, chocolate).
likes(mary, wine).
likes(john, wine).
likes(john, mary).

% Define the query rule to find pairs X and Y where john likes X and X likes Y
query :-
    likes(john, X),
    likes(X, Y),
    format('X = ~w, Y = ~w~n', [X, Y]).
```
@LIA.prolog_withShell

### Python2 : `@LIA.python2`

Python 2 is a version of the Python programming language that was widely used for many years, first released in 2000. It is known for its simplicity, readability, and versatility, making it popular for web development, automation, data analysis, and scripting. Python 2 introduced many features that made Python a popular choice among developers, but it also had some design limitations that led to the development of Python 3. Python 2.7, the last release of Python 2, reached its end of life on January 1, 2020, meaning it no longer receives updates or support. The backend here uses the Python 2 interpreter to execute Python 2 code, ensuring compatibility with legacy systems and software that still rely on this version.

For more information, you can visit the [Python 2 programming language Wikipedia page](https://en.wikipedia.org/wiki/CPython#Version_history).

---

```python
for i in range(10):
  print "Hallo Welt", i
```
@LIA.python2

---

Additionally, you can also use the `@LIA.python2_withShell` macro, which will start a Python 2 shell after the code has been executed.

```python
for i in range(10):
  print "Hallo Welt", i
```
@LIA.python2_withShell


### Python3 : `@LIA.python3`

Python 3 is the current and actively maintained version of the Python programming language, first released in 2008. It was developed to address and improve upon the limitations of Python 2, introducing several key features like better Unicode support, a more consistent and intuitive syntax, and enhancements in performance and standard library functionality. Python 3 is widely used for web development, data science, machine learning, automation, and scripting. It is known for its readability, ease of use, and extensive ecosystem of libraries and frameworks. The backend here uses the Python 3 interpreter to execute Python 3 code, ensuring compatibility with modern Python applications and libraries.

For more information, you can visit the [Python 3 programming language Wikipedia page](https://en.wikipedia.org/wiki/CPython#Version_history).

---

```python
for i in range(10):
  print("Hallo Welt", i)
```
@LIA.python3


---

Additionally, you can also use the `@LIA.python3_withShell` macro, which will start a Python 3 shell after the code has been executed.

```python
for i in range(10):
  print("Hallo Welt", i)
```
@LIA.python3_withShell

---

If you want to pass multiple files for data processing, you can use the `@LIA.eval` macro, which allows you to define all settings manually.


```text -data.csv 
A,B,C
0,0.1,3
1,0.3,5
2,0.4,2
```
```python readCSV.py
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data.csv', header = 0)  
df.plot.scatter(x='A', y='B')
plt.savefig('temp.png')
```
@LIA.eval(`["data.csv", "main.py"]`, `none`, `python3 main.py`, `*`)

### Q# : `@LIA.qsharp`

Q# is a domain-specific programming language developed by Microsoft for quantum computing. It is designed to express quantum algorithms, operations, and simulations in a high-level, expressive manner. Q# provides a rich set of features for developing quantum programs, including quantum data types, quantum operations, and quantum simulators. It is integrated with the Microsoft Quantum Development Kit, which includes a quantum simulator and tools for developing, testing, and debugging quantum programs. The backend here uses the Q# compiler to compile Q# code, ensuring compatibility with quantum hardware and simulators.

For more information, you can visit the [Q# programming language Wikipedia page](https://en.wikipedia.org/wiki/Q_Sharp).

---

```qsharp
namespace HelloWorld {
    open Microsoft.Quantum.Intrinsic;

    operation SayHello() : Unit {
        Message("Hello, world!");
    }
}
```
@LIA.eval(`["HelloWorld.qs"]`, `dotnet build`, `dotnet run`)

### R : `@LIA.r`

R is a high-level programming language and environment specifically designed for statistical computing and data analysis. First released in 1995 by Ross Ihaka and Robert Gentleman, R is widely used among statisticians, data scientists, and researchers for its powerful statistical packages and data visualization capabilities. It supports a wide range of statistical techniques, from linear and nonlinear modeling to time-series analysis and clustering. R's rich ecosystem of packages and libraries, combined with its scripting capabilities and interactive data analysis features, makes it a preferred choice for data manipulation and graphical representation. The backend here uses the R interpreter to execute R scripts, ensuring robust statistical analysis and data handling.

For more information, you can visit the [R programming language Wikipedia page](https://en.wikipedia.org/wiki/R_%28programming_language%29).

---

``` R
library(ggplot2)

# Use stdout as per normal...
print("Hello, world!")

# Use plots...
png(file="out1.png")
plot(cars)

# Even ggplot!
png(file="out2.png")
qplot(wt, mpg, data = mtcars, colour = factor(cyl))
```
@LIA.r

---

Additionally, you can also use the `@LIA.r_withShell` macro, which will start an R shell after the code has been executed.

``` R
print("Hello World")
```
@LIA.r_withShell

### Racket : `@LIA.racket`

Racket is a general-purpose, multi-paradigm programming language that was developed as a descendant of the Scheme programming language. It is known for its extensibility, expressive syntax, and powerful macro system, making it ideal for language-oriented programming, domain-specific languages, and software development. Racket provides a rich set of libraries and tools for building web applications, graphical user interfaces, and educational software. It is widely used in academia and industry for research, teaching, and prototyping. The backend here uses the Racket interpreter to execute Racket code, ensuring efficient and reliable performance.

For more information, you can visit the [Racket programming language Wikipedia page](https://en.wikipedia.org/wiki/Racket_%28programming_language%29).

---

```racket
#lang racket
(displayln "Hello, world!")
```
@LIA.racket

### REXX : `@LIA.rexx`

REXX (Restructured Extended Executor) is a high-level, procedural programming language developed by IBM in the late 1970s. It is known for its simplicity, readability, and ease of use, making it ideal for scripting, automation, and system administration tasks. REXX provides a rich set of built-in functions and features for string manipulation, file processing, and program control. It is widely used in mainframe environments, such as IBM z/OS, as well as in cross-platform scripting and automation. The backend here uses the Regina REXX interpreter to execute REXX code, ensuring compatibility and efficient execution.

For more information, you can visit the [REXX programming language Wikipedia page](https://en.wikipedia.org/wiki/REXX).

---

```rexx
/* REXX program to display "Hello, world!" */
say "Hello, world!"
```
@LIA.eval(`["hello.rexx"]`, `none`, `rexx hello.rexx`)

### Ruby : `@LIA.ruby`

Ruby is a high-level, interpreted programming language known for its simplicity and productivity. Developed by Yukihiro Matsumoto and first released in 1995, Ruby emphasizes ease of use and developer happiness, featuring a clean and elegant syntax that is easy to read and write. It supports multiple programming paradigms, including object-oriented, functional, and imperative programming. Ruby is particularly renowned for its use in web development, especially with the Ruby on Rails framework, which facilitates rapid development and deployment of web applications. The backend here uses the Ruby interpreter to execute Ruby code, ensuring efficient execution and support for modern Ruby features.

For more information, you can visit the [Ruby programming language Wikipedia page](https://en.wikipedia.org/wiki/Ruby_%28programming_language%29).

---

```ruby
class HelloWorld
   def initialize(name)
      @name = name.capitalize
   end
   def sayHi
      puts "Hello #{@name}!"
   end
end

hello = HelloWorld.new("World")
hello.sayHi
```
@LIA.ruby

---

Additionally, you can also use the `@LIA.ruby_withShell` macro, which will start an IRB shell after the code has been executed.

```ruby
class HelloWorld
   def initialize(name)
      @name = name.capitalize
   end
   def sayHi
      puts "Hello #{@name}!"
   end
end

hello = HelloWorld.new("World")
hello.sayHi
```
@LIA.ruby_withShell

### Rust : `@LIA.rust`

**Rust Language Summary:**

Rust is a systems programming language that focuses on safety, performance, and concurrency. It was first released in 2010 by Mozilla and has gained significant popularity for its ability to provide memory safety without a garbage collector. Rust combines the performance characteristics of languages like C++ with modern features such as strong static typing, ownership, and borrowing, which help prevent common programming errors like null pointer dereferences and data races. Rust is well-suited for systems programming, web assembly, and high-performance applications. The backend here uses the Rust compiler to compile Rust code, ensuring efficient, safe, and reliable execution.

For more information, you can visit the [Rust programming language Wikipedia page](https://en.wikipedia.org/wiki/Rust_%28programming_language%29).

``` rust
fn main() {
  println!("Hello World!");
}
```
@LIA.rust

### SelectScript : `@LIA.selectscript`

https://github.com/andre-dietrich/SelectScriptC/tree/master

``` sql
mov
  = PROC(Tower, frm, to)
    "A simple tower move function that returns a new tower configuration:
     mov([[3,2,1], [], []], 0, 1) -> [[3,2], [1], []]

     In case of an unalowed move a None value gets returned:
     mov([[3,2], [1], []], 0, 1)  -> None "
    : ( IF( $Tower == None, EXIT None);

        IF( not $Tower[$frm], EXIT None);

        IF( $Tower[$to],
            IF( $Tower[$frm][-1] > $Tower[$to][-1],
                EXIT None));

        $Tower[$to]@+( $Tower[$frm][-1] );
        $Tower[$frm]@pop();
        $Tower;
      );


# initial tower configuration
tower = [[3,2,1], [], []];

# allowed moves [from, to]
moves = [[0,1], [0,2], [1,0], [1,2], [2,0], [2,1]];

# goal configuration
finish = [[], [], [3,2,1]];



# vanilla-approach: recusively test all combinations for 7 moves
$start_time = time();
rslt1 = SELECT [$m1, $m2, $m3, $m4, $m5, $m6, $m7]
          FROM m1:moves, m2:moves, m3:moves, m4:moves,
               m5:moves, m6:moves, m7:moves
         WHERE finish == (tower
                          |> mov($m1[0], $m1[1])
                          |> mov($m2[0], $m2[1])
                          |> mov($m3[0], $m3[1])
                          |> mov($m4[0], $m4[1])
                          |> mov($m5[0], $m5[1])
                          |> mov($m6[0], $m6[1])
                          |> mov($m7[0], $m7[1]))
           AS list;

print("######################################################################");
print("first vanilla-approach search");
print("time:   ", time()-$start_time);
print("result: ", rslt1);



$start_time = time();
rslt2 = SELECT $m
          FROM m:moves
         WHERE finish == mov($tower, $m[0], $m[1])
    START WITH $tower = tower
    CONNECT BY $tower@mov($m[0], $m[1])
     STOP WITH $tower == None OR $step$ > 6
            AS list;

print("######################################################################");
print("simple CONNECT BY (recursive search)");
print("time:   ", time()-$start_time);
print("result: ", rslt2);



$start_time = time();
rslt3 = SELECT $tower
          FROM m:moves
         WHERE finish == mov($tower, $m[0], $m[1])
    START WITH $tower = tower
    CONNECT BY NO CYCLE
               $tower@mov($m[0], $m[1])
     STOP WITH $tower == None OR $step$ > 6
            AS LIST;

print("######################################################################");
print("CONNECT BY with no cycles");
print("time:   ", time()-$start_time);
print("result: ", rslt3);


rslt4 = SELECT $step$, $tower, $m
          FROM m:moves
         WHERE finish == mov($tower, $m[0], $m[1])
    START WITH $tower = tower
    CONNECT BY UNIQUE
               $tower@mov($m[0], $m[1])
     STOP WITH $tower == None OR $step$ > 7
            AS LIST;

print("######################################################################");
print("CONNECT BY with UNIQUE");
print("time:   ", time()-$start_time);
print("result: ", rslt4);


True;
```
@LIA.selectscript


### Solidity : `@LIA.solidity`

Solidity is a high-level, statically typed programming language designed for writing smart contracts on the Ethereum blockchain. It was developed by Gavin Wood, Christian Reitwiessner, and others in 2014 as part of the Ethereum project. Solidity is known for its simplicity, security, and efficiency, making it ideal for creating decentralized applications (dApps) and automated contracts that run on the Ethereum Virtual Machine (EVM). Solidity supports object-oriented programming features, including inheritance, interfaces, and libraries, allowing developers to build complex smart contracts with reusable components. The backend here uses the Solidity compiler to compile Solidity code, ensuring compatibility with the Ethereum blockchain and efficient execution.

For more information, you can visit the [Solidity programming language Wikipedia page](https://en.wikipedia.org/wiki/Solidity).

---

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    string public message;

    constructor() {
        message = "Hello, world!";
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}
```
@LIA.eval(`["HelloWorld.sol"]`, `none`, `solcjs --abi HelloWorld.sol`)

### Scala : `@LIA.scala`

Scala is a modern, functional programming language that runs on the Java Virtual Machine (JVM). It was developed by Martin Odersky and first released in 2003. Scala combines object-oriented and functional programming paradigms, providing a powerful and expressive language for building scalable and robust applications. Scala is known for its conciseness, type safety, and interoperability with Java, making it a popular choice for developing web services, distributed systems, and data processing applications. The backend here uses the Scala compiler to execute Scala code, ensuring efficient performance on the JVM.

For more information, you can visit the [Scala programming language Wikipedia page](https://en.wikipedia.org/wiki/Scala_%28programming_language%29).

---

```scala
object HelloWorld {
  def main(args: Array[String]): Unit = {
    println("Hello, world!")
  }
}
```
@LIA.scala(HelloWorld)

### Scheme : `@LIA.scheme`

Scheme is a minimalist, functional programming language that was developed in the 1970s as a dialect of Lisp. It is known for its simplicity, elegance, and expressive power, making it an ideal language for teaching programming concepts and exploring functional programming paradigms. Scheme features a simple syntax based on s-expressions and a powerful macro system that allows for easy metaprogramming. It is widely used in academic settings and research for its clarity and ease of understanding. The backend here uses the Scheme interpreter to execute Scheme code, ensuring efficient and reliable performance.

For more information, you can visit the [Scheme programming language Wikipedia page](https://en.wikipedia.org/wiki/Scheme_%28programming_language%29).

---

```scheme
(display "Hello, world!")
(newline)
```
@LIA.scheme

### Smalltalk : `@LIA.smalltalk`

Smalltalk is an object-oriented, dynamically typed programming language that was developed in the 1970s at Xerox PARC. It is known for its simplicity, elegance, and powerful object model, making it an ideal language for teaching object-oriented programming concepts. Smalltalk features a live programming environment where developers can interact with objects directly, making it easy to explore and modify code in real time. Smalltalk has influenced many modern programming languages, including Java, Ruby, and Python. The backend here uses the Squeak Smalltalk interpreter to execute Smalltalk code, ensuring interactive and dynamic programming capabilities.

For more information, you can visit the [Smalltalk programming language Wikipedia page](https://en.wikipedia.org/wiki/Smalltalk).

---

```smalltalk
'Hello, world!' displayNl
```
@LIA.smalltalk

### Standard ML : `@LIA.sml`

Standard ML (SML) is a functional programming language that was developed in the 1980s as a standardized version of the ML programming language. It is known for its strong type system, pattern matching, and type inference capabilities, making it ideal for developing reliable and efficient software. SML features a clean and expressive syntax that emphasizes functional programming concepts, such as higher-order functions, currying, and immutability. It is widely used in academia and research for teaching programming languages and compiler construction. The backend here uses the SML/NJ compiler to execute Standard ML code, ensuring compatibility and efficient execution.

For more information, you can visit the [Standard ML programming language Wikipedia page](https://en.wikipedia.org/wiki/Standard_ML).

---

``` sml
print "Hello, world!\n";
```
@LIA.eval(`["main.sml"]`, `none`, `sml main.sml`)

### TCL : `@LIA.tcl`

Tcl (Tool Command Language) is a high-level, interpreted programming language known for its simplicity, flexibility, and extensibility. Developed by John Ousterhout in the late 1980s, Tcl is designed to be easy to learn and use, with a minimalistic syntax that emphasizes commands and procedures. Tcl is widely used for scripting, automation, and rapid prototyping, as well as for embedding in applications and extending with custom functionality. The backend here uses the Tcl interpreter to execute Tcl code, ensuring compatibility and efficient execution.

For more information, you can visit the [Tcl programming language Wikipedia page](https://en.wikipedia.org/wiki/Tcl).

---

```tcl
puts "Hello, world!"
```
@LIA.tcl


### Vala : `@LIA.vala`

Vala is a high-level, object-oriented programming language developed by Jürg Billeter and Raffaele Sandrini in 2006. It is designed to be a modern alternative to C and C++, with a focus on simplicity, performance, and ease of use. Vala is known for its clean syntax, memory safety, and interoperability with existing libraries and frameworks. It is widely used for developing desktop applications, system utilities, and software libraries. Vala compiles to C code and uses the GObject system for object-oriented programming, making it compatible with the GNOME ecosystem. The backend here uses the Vala compiler to compile Vala code, ensuring efficient execution and compatibility with the GNOME platform.

For more information, you can visit the [Vala programming language Wikipedia page](https://en.wikipedia.org/wiki/Vala_%28programming_language%29).

---

```vala
void main () {
    print ("Hello, world!\n");
}
```
@LIA.eval(`["main.vala"]`, `valac main.vala -o main`, `./main`)

### V : `@LIA.v`

V is a statically typed, compiled programming language designed for simplicity, performance, and safety. It was created by Alexander Medvednikov and first released in 2020. V aims to be a lightweight language that is easy to learn and use, with a syntax that is straightforward and similar to Go and Python. It focuses on providing a high level of efficiency while maintaining readability and ease of use. V supports both procedural and functional programming paradigms and is designed to compile to native machine code, resulting in fast execution and minimal runtime dependencies. The backend here uses the V compiler to compile V code, ensuring efficient and reliable performance.

For more information, you can visit the [V programming language Wikipedia page](https://en.wikipedia.org/wiki/V_%28programming_language%29).

---

```v
println("Hello World")
```
@LIA.v

---

Additionally, you can also use the `@LIA.v_withShell` macro, which will start a V shell after the code has been executed.

```v
println("Hello World")
```
@LIA.v_withShell

### Verilog : `@LIA.verilog`

Verilog is a hardware description language (HDL) used for designing digital circuits and systems. It was first introduced in the 1980s and has since become a standard language for modeling and simulating digital circuits. Verilog is known for its simplicity, expressiveness, and support for both behavioral and structural modeling of hardware components. It is widely used in the semiconductor industry for designing integrated circuits, field-programmable gate arrays (FPGAs), and other digital systems. The backend here uses the Icarus Verilog simulator to execute Verilog code, ensuring compatibility and efficient simulation of digital circuits.

For more information, you can visit the [Verilog programming language Wikipedia page](https://en.wikipedia.org/wiki/Verilog).

---

```verilog
module hello_world;
  initial begin
    $display("Hello, world!");
    $finish;
  end
endmodule
```
@LIA.verilog

### VHDL : `@LIA.vhdl`

VHDL (VHSIC Hardware Description Language) is a hardware description language used for designing digital circuits and systems. It was developed in the 1980s as part of the U.S. Department of Defense's VHSIC (Very High-Speed Integrated Circuit) program. VHDL is known for its versatility, expressiveness, and support for both behavioral and structural modeling of hardware components. It is widely used in the semiconductor industry for designing integrated circuits, field-programmable gate arrays (FPGAs), and other digital systems. The backend here uses the GHDL simulator to execute VHDL code, ensuring compatibility and efficient simulation of digital circuits.

For more information, you can visit the [VHDL programming language Wikipedia page](https://en.wikipedia.org/wiki/VHDL).

---

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity hello_world is
end hello_world;

architecture rtl of hello_world is
begin
  process
  begin
    report "Hello, world!";
    wait;
  end process;
end rtl;
```
@LIA.vhdl(hello_world)

### Zig : `@LIA.zig`

Zig is a general-purpose, statically typed programming language designed for robustness, optimality, and clarity. It was first released in 2016 by Andrew Kelley. Zig aims to offer a modern alternative to C with improved safety and performance features, including manual memory management, a comprehensive standard library, and support for cross-compilation. The language provides fine-grained control over system resources and emphasizes compile-time checks and correctness. Zig's syntax is designed to be simple and expressive, making it suitable for systems programming, embedded development, and performance-critical applications. The backend here uses the Zig compiler to compile Zig code, ensuring efficient execution and cross-platform compatibility.

For more information, you can visit the [Zig programming language Wikipedia page](https://en.wikipedia.org/wiki/Zig_%28programming_language%29).

---

```zig
const std = @import("std");

pub fn main() void {
    std.io.getStdOut().writeAll(
        "Hello World!",
    ) catch unreachable;
}
```
@LIA.zig

## `@LIA.evalWithDebug`

This does basically the same as `@LIA.eval`, but it will add additional
Debug-information about the CodeRunner status to the console.


```c
#include <stdio.h>

int main (void){
	int i = 0;
	int max = 0;

	printf("How many hellos: ");
	scanf("%d",&max);

  for(i=0; i<max; i++)
    printf ("Hello, world %d!\n", i);

	return 0;
}
```
@LIA.evalWithDebug(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)


## Deploying to Heroku

If you deploy this to heroku, as we do, keep in mind, that the __free__ service
will be shut down, if no one uses it for 30 minutes, it takes round about 30
sec. to resurrect.

1. Install the [Heroku-CLI](https://devcenter.heroku.com/articles/heroku-cli)
2. Create a new Heroku project

   1. Login to Heroku: `heroku login` (Don't use sudo or it will not work!)
   2. Create the project: `heroku create [app_name]`

3. Login to Heroku container: `heroku container:login` (It's important
   that you have docker installed before executing this command
   and [make sure that your user is added to the docker group](https://docs.docker.com/engine/install/linux-postinstall/).)
4. Build the docker container and upload it to heroku:

   `docker build . -t web`

   `heroku container:push web -a app_name`

5. Release the docker container: `heroku container:release web -a app_name`

Your project url is now `app_name.herokuapp.com`. (Or the auto-generated one
when you haven't supplied an app name.)

If you deploy your own server, you have to change the websocket-url in the main
header (main HTML comment of your Markdown document) from
`wss://liarunner.herokuapp.com/socket` to `wss://*******.herokuapp.com/socket` ...
what ever the name of your app is ...


## Implementation


                              --{{0}}--
If you want to minimize loading effort in your LiaScript project, you can also
copy this code and paste it into your main comment header, see the code in the
raw file of this document.

{{1}} https://raw.githubusercontent.com/liaScript/CodeRunner/master/README.md

```` js
@onload
window.CodeRunner = {
    ws: undefined,
    handler: {},
    connected: false,
    error: "",
    url: "",
    firstConnection: true,

    init(url, step = 0) {
        this.url = url
        if (step  >= 10) {
           console.warn("could not establish connection")
           this.error = "could not establish connection to => " + url
           return
        }

        this.ws = new WebSocket(url);

        const self = this
        
        const connectionTimeout = setTimeout(() => {
          self.ws.close();
          console.log("WebSocket connection timed out");
        }, 5000);
        
        
        this.ws.onopen = function () {
            clearTimeout(connectionTimeout);
            self.log("connections established");

            self.connected = true
            
            setInterval(function() {
                self.ws.send("ping")
            }, 15000);
        }
        this.ws.onmessage = function (e) {
            // e.data contains received string.

            let data
            try {
                data = JSON.parse(e.data)
            } catch (e) {
                self.warn("received message could not be handled =>", e.data)
            }
            if (data) {
                self.handler[data.uid](data)
            }
        }
        this.ws.onclose = function () {
            clearTimeout(connectionTimeout);
            self.connected = false
            self.warn("connection closed ... reconnecting")

            setTimeout(function(){
                console.warn("....", step+1)
                self.init(url, step+1)
            }, 1000)
        }
        this.ws.onerror = function (e) {
            clearTimeout(connectionTimeout);
            self.warn("an error has occurred")
        }
    },
    log(...args) {
        window.console.log("CodeRunner:", ...args)
    },
    warn(...args) {
        window.console.warn("CodeRunner:", ...args)
    },
    handle(uid, callback) {
        this.handler[uid] = callback
    },
    send(uid, message, sender=null, restart=false) {
        const self = this
        if (this.connected) {
          message.uid = uid
          this.ws.send(JSON.stringify(message))
        } else if (this.error) {

          if(restart) {
            sender.lia("LIA: terminal")
            this.error = ""
            this.init(this.url)
            setTimeout(function() {
              self.send(uid, message, sender, false)
            }, 2000)

          } else {
            //sender.lia("LIA: wait")
            setTimeout(() => {
              sender.lia(" " + this.error)
              sender.lia(" Maybe reloading fixes the problem ...")
              sender.lia("LIA: stop")
            }, 800)
          }
        } else {
          setTimeout(function() {
            self.send(uid, message, sender, false)
          }, 2000)
          
          if (sender) {
            
            sender.lia("LIA: terminal")
            if (this.firstConnection) {
              this.firstConnection = false
              setTimeout(() => { 
                sender.log("stream", "", [" Waking up execution server ...\n", "This may take up to 30 seconds ...\n", "Please be patient ...\n"])
              }, 100)
            } else {
              sender.log("stream", "", ".")
            }
            sender.lia("LIA: terminal")
          }
        }
    }
}

//window.CodeRunner.init("wss://coderunner.informatik.tu-freiberg.de/")
//window.CodeRunner.init("ws://localhost:4000/")
window.CodeRunner.init("wss://ancient-hollows-41316.herokuapp.com/")
@end


@LIA.ada:               @LIA.eval(`["main.ada"]`, `gnatmake main.ada`, `./main`)
@LIA.algol:             @LIA.eval(`["main.alg"]`, `none`, `a68g main.alg`)
@LIA.apl:               @LIA.eval(`["main.apl"]`, `none`, `dyalog -script main.apl`)
@LIA.awk:               @LIA.eval(`["main.awk"]`, `none`, `awk -f main.awk`)
@LIA.basic:             @LIA.eval(`["main.bas"]`, `none`, `bwbasic main.bas`)
@LIA.c:                 @LIA.eval(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)
@LIA.clojure:           @LIA.eval(`["main.clj"]`, `none`, `clojure -M main.clj`)
@LIA.clojure_withShell: @LIA.eval(`["main.clj"]`, `none`, `clojure -M -i main.clj -r`)
@LIA.cpp:               @LIA.eval(`["main.cpp"]`, `g++ main.cpp -o a.out`, `./a.out`)
@LIA.cobol:             @LIA.eval(`["main.cob"]`, `cobc -x --free main.cob`, `./main`)
@LIA.coq:               @LIA.eval(`["file.v"]`, `coqc file.v`, `coqtop -lv file.v`)
@LIA.d:                 @LIA.eval(`["main.d"]`, `gdc main.d`, `./a.out`)
@LIA.elixir:            @LIA.eval(`["main.exs"]`, `none`, `elixir main.exs`)
@LIA.elixir_withShell:  @LIA.eval(`["main.exs"]`, `none`, `iex main.exs`)
@LIA.erlang:            @LIA.eval(`["hello.erl"]`, `erlc hello.erl`, `erl -noshell -s hello hello -s init stop`)
@LIA.erlang_withShell:  @LIA.eval(`["hello.erl"]`, `erlc hello.erl`, `erl -noshell -s hello hello`)
@LIA.forth:             @LIA.eval(`["main.fs"]`, `none`, `gforth main.fs -e BYE`)
@LIA.forth_withShell:   @LIA.eval(`["main.fs"]`, `none`, `gforth main.fs`)
@LIA.fortran:           @LIA.eval(`["main.f90"]`, `gfortran main.f90 -o a.out`, `./a.out`)
@LIA.go:                @LIA.eval(`["main.go"]`, `go build main.go`, `./main`)
@LIA.groovy:            @LIA.eval(`["main.groovy"]`, `none`, `groovy main.groovy`)
@LIA.haskell:           @LIA.eval(`["main.hs"]`, `ghc main.hs -o main`, `./main`)
@LIA.haskell_withShell: @LIA.eval(`["main.hs"]`, `none`, `ghci main.hs`)
@LIA.haxe:              @LIA.eval(`["Main.hx"]`, `none`, `haxe -main Main --interp`)
@LIA.inform:            @LIA.eval(`["main.inf"]`, `inform -o main.inf > compile.log && [ -f "main.z5" ] || { cat compile.log >&2; exit 1; }`, `/usr/games/dfrotz main.z5`)
@LIA.io:                @LIA.eval(`["main.io"]`, `none`, `io main.io`)
@LIA.io_withShell:      @LIA.eval(`["main.io"]`, `none`, `io -i main.io`)
@LIA.java:              @LIA.eval(`["@0.java"]`, `javac @0.java`, `java @0`)
@LIA.julia:             @LIA.eval(`["main.jl"]`, `none`, `julia main.jl`)
@LIA.julia_withShell:   @LIA.eval(`["main.jl"]`, `none`, `julia -i main.jl`)
@LIA.kotlin:            @LIA.eval(`["main.kt"]`, `kotlinc main.kt -include-runtime -d main.jar`, `java -jar main.jar`)
@LIA.lua:               @LIA.eval(`["main.lua"]`, `none`, `lua main.lua`)
@LIA.mono:              @LIA.eval(`["main.cs"]`, `mcs main.cs`, `mono main.exe`)
@LIA.nasm:              @LIA.eval(`["main.asm"]`, `nasm -felf64 main.asm && ld main.o`, `./a.out`)
@LIA.nim:               @LIA.eval(`["main.nim"]`, `nim c main.nim`, `./main`)
@LIA.nodejs:            @LIA.eval(`["main.js"]`, `none`, `node main.js`)
@LIA.ocaml:             @LIA.eval(`["main.ml"]`, `none`, `ocaml main.ml`)
@LIA.perl:              @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl main.pl`)
@LIA.perl_withShell:    @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl -d main.pl`)
@LIA.php:               @LIA.eval(`["main.php"]`, `none`, `php main.php`)
@LIA.postscript:        @LIA.eval(`["input.ps"]`, `none`, `gs -sDEVICE=png16m -r300 -o output.png input.ps`)
@LIA.prolog:            @LIA.eval(`["main.pl"]`, `none`, `swipl -s main.pl -g @0 -t halt`)
@LIA.prolog_withShell:  @LIA.eval(`["main.pl"]`, `none`, `swipl -s main.pl`)
@LIA.python:            @LIA.python3
@LIA.python_withShell:  @LIA.python3_withShell
@LIA.python2:           @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 main.pyc`)
@LIA.python2_withShell: @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 -i main.pyc`)
@LIA.python3:           @LIA.eval(`["main.py"]`, `none`, `python3 main.py`)
@LIA.python3_withShell: @LIA.eval(`["main.py"]`, `none`, `python3 -i main.py`)
@LIA.r:                 @LIA.eval(`["main.R"]`, `none`, `Rscript main.R`)
@LIA.r_withShell:       @LIA.eval(`["main.R"]`, `none`, `sh -c "cat main.R - | R --interactive"`)
@LIA.racket:            @LIA.eval(`["main.rkt"]`, `none`, `racket main.rkt`)
@LIA.ruby:              @LIA.eval(`["main.rb"]`, `none`, `ruby main.rb`)
@LIA.ruby_withShell:    @LIA.eval(`["main.rb"]`, `none`, `irb --nomultiline -r ./main.rb`)
@LIA.rust:              @LIA.eval(`["main.rs"]`, `rustc main.rs`, `./main`)
@LIA.scala:             @LIA.eval(`["@0.scala"]`, `scalac @0.scala`, `scala @0`)
@LIA.scheme:            @LIA.eval(`["main.scm"]`, `none`, `guile --no-auto-compile main.scm`)
@LIA.selectscript:      @LIA.eval(`["main.s2"]`, `none`, `S2c -x main.s2`)
@LIA.smalltalk:         @LIA.eval(`["main.st"]`, `none`, `gst main.st`)
@LIA.tcl:               @LIA.eval(`["main.tcl"]`, `none`, `tclsh main.tcl`)
@LIA.v:                 @LIA.eval(`["main.v"]`, `v main.v`, `./main`)
@LIA.v_withShell:       @LIA.eval(`["main.v"]`, `none`, `sh -c "cat main.v - | v repl"`)
@LIA.verilog:           @LIA.eval(`["main.v"]`, `iverilog -o main.vvp main.v`, `vvp main.vvp`)
@LIA.vhdl:              @LIA.eval(`["@0.vhdl"]`, `ghdl -a @0.vhdl && ghdl -e @0`, `ghdl -r @0`)
@LIA.zig:               @LIA.eval(`["main.zig"]`, `zig build-exe ./main.zig -O ReleaseSmall`, `./main`)

@LIA.dotnet
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
```
@LIA.eval(`["Program.cs","project.csproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.fsharp
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.qsharp
```xml    -project.csproj
<Project Sdk="Microsoft.Quantum.Sdk/0.28.302812">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
</Project>
```
@LIA.eval(`["Program.qs", "project.csproj"]`, `dotnet build -nologo`, `dotnet run`)
@end

@LIA.eval:  @LIA.eval_(false,`@0`,@1,@2,@3)

@LIA.evalWithDebug: @LIA.eval_(true,`@0`,@1,@2,@3)

@LIA.eval_
<script>
function random(len=16) {
    let chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let str = '';
    for (let i = 0; i < len; i++) {
        str += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return str;
}



const uid = random()
var order = @1
var files = []

var pattern = "@4".trim()

if (pattern.startsWith("\`")){
  pattern = pattern.slice(1,-1)
} else if (pattern.length === 2 && pattern[0] === "@") {
  pattern = null
}

if (order[0])
  files.push([order[0], `@'input(0)`])
if (order[1])
  files.push([order[1], `@'input(1)`])
if (order[2])
  files.push([order[2], `@'input(2)`])
if (order[3])
  files.push([order[3], `@'input(3)`])
if (order[4])
  files.push([order[4], `@'input(4)`])
if (order[5])
  files.push([order[5], `@'input(5)`])
if (order[6])
  files.push([order[6], `@'input(6)`])
if (order[7])
  files.push([order[7], `@'input(7)`])
if (order[8])
  files.push([order[8], `@'input(8)`])
if (order[9])
  files.push([order[9], `@'input(9)`])


send.handle("input", (e) => {
    CodeRunner.send(uid, {stdin: e}, send)
})
send.handle("stop",  (e) => {
    CodeRunner.send(uid, {stop: true}, send)
});


CodeRunner.handle(uid, function (msg) {
    switch (msg.service) {
        case 'data': {
            if (msg.ok) {
                CodeRunner.send(uid, {compile: @2}, send)
            }
            else {
                send.lia("LIA: stop")
            }
            break;
        }
        case 'compile': {
            if (msg.ok) {
                if (msg.message) {
                    if (msg.problems.length)
                        console.warn(msg.message);
                    else
                        console.log(msg.message);
                }

                send.lia("LIA: terminal")
                CodeRunner.send(uid, {exec: @3, filter: pattern})

                if(!@0) {
                  console.clear()
                }
            } else {
                send.lia(msg.message, msg.problems, false)
                send.lia("LIA: stop")
            }
            break;
        }
        case 'stdout': {
            if (msg.ok)
                console.stream(msg.data)
            else
                console.error(msg.data);
            break;
        }

        case 'stop': {
            if (msg.error) {
                console.error(msg.error);
            }

            if (msg.images) {
                for(let i = 0; i < msg.images.length; i++) {
                    console.html("<hr/>", msg.images[i].file)
                    console.html("<img title='" + msg.images[i].file + "' src='" + msg.images[i].data + "' onclick='window.LIA.img.click(\"" + msg.images[i].data + "\")'>")
                }
            }

            if (msg.videos) {
                for(let i = 0; i < msg.videos.length; i++) {
                    console.html("<hr/>", msg.videos[i].file)
                    console.html("<video controls style='width:100%' title='" + msg.videos[i].file + "' src='" + msg.videos[i].data + "'></video>")
                }
            }

            if (msg.files) {
                let str = "<hr/>"
                for(let i = 0; i < msg.files.length; i++) {
                    str += `<a href='data:application/octet-stream${msg.files[i].data}' download="${msg.files[i].file}">${msg.files[i].file}</a> `
                }

                console.html(str)
            }

            window.console.warn(msg)

            send.lia("LIA: stop")
            break;
        }

        default:
            console.log(msg)
            break;
    }
})


CodeRunner.send(
    uid, { "data": files }, send, true
);

"LIA: wait"
</script>
@end
````

## Deployment

### Heroku

Change the Dockerfile to:

``` yaml
...
# EXPOSE 8000

# ENTRYPOINT python3 -m server
CMD python3 -m server --host 0.0.0.0 --port $PORT
```

The host has to be set to `0.0.0.0` and the port is set by heroku itself.

Afterwards repeat the following steps:

``` bash
$ heroku container:login
  ...
  Login Succeeded

$ heroku create
  Creating app... done, ⬢ XXXXXX-XXXXXXX-XXXXXX
  https://XXXXXX-XXXXXXX-XXXXXX.herokuapp.com/ | https://git.heroku.com/XXXXXX-XXXXXXX-XXXXXX.git

$ heroku container:push web
  === Building web (.../CodeRunner/Dockerfile)
  Sending build context to Docker daemon  4.633MB
  Step 1/35 : FROM ubuntu:kinetic
   ---> d6547859cd2f
  Step 2/35 : RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing
   ---> Using cache
  ...
  
  Step 35/35 : CMD python3 -m server --host 0.0.0.0 --port $PORT
   ---> Running in bde2634a12ba
  ...
  
  Successfully built 50ec74c6e81f
  Successfully tagged registry.heroku.com/XXXXXX-XXXXXXX-XXXXXX/web:latest
  === Pushing web (.../CodeRunner/Dockerfile)
  Using default tag: latest
  The push refers to repository [registry.heroku.com/XXXXXX-XXXXXXX-XXXXXX/web]
  ...
  Your image has been successfully pushed. You can now release it with the 'container:release' command.

$ heroku container:release web
  Releasing images web to XXXXXX-XXXXXXX-XXXXXX... done 
```
