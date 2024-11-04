<!--
author:   André Dietrich

email:    LiaScript@web.de

version:  0.0.3

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
window.CodeRunner.init("ws://127.0.0.1:8001/")
//window.CodeRunner.init("wss://ancient-hollows-41316.herokuapp.com/")
@end


@LIA.ada:               @LIA.eval(`["main.ada"]`, `gnatmake main.ada`, `./main`)
@LIA.c:                 @LIA.eval(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)
@LIA.clojure:           @LIA.eval(`["main.clj"]`, `none`, `clojure -M main.clj`)
@LIA.clojure_withShell: @LIA.eval(`["main.clj"]`, `none`, `clojure -M -i main.clj -r`)
@LIA.cpp:               @LIA.eval(`["main.cpp"]`, `g++ main.cpp -o a.out`, `./a.out`)
@LIA.cobol:             @LIA.eval(`["main.cob"]`, `cobc -x --free main.cob`, `./main`)
@LIA.elixir:            @LIA.eval(`["main.exs"]`, `none`, `elixir main.exs`)
@LIA.elixir_withShell:  @LIA.eval(`["main.exs"]`, `none`, `iex main.exs`)
@LIA.go:                @LIA.eval(`["main.go"]`, `go build main.go`, `./main`)
@LIA.haskell:           @LIA.eval(`["main.hs"]`, `ghc main.hs -o main`, `./main`)
@LIA.haskell_withShell: @LIA.eval(`["main.hs"]`, `none`, `ghci main.hs`)
@LIA.java:              @LIA.eval(`["@0.java"]`, `javac @0.java`, `java @0`)
@LIA.julia:             @LIA.eval(`["main.jl"]`, `none`, `julia main.jl`)
@LIA.julia_withShell:   @LIA.eval(`["main.jl"]`, `none`, `julia -i main.jl`)
@LIA.mono:              @LIA.eval(`["main.cs"]`, `mcs main.cs`, `mono main.exe`)
@LIA.nasm:              @LIA.eval(`["main.asm"]`, `nasm -felf64 main.asm && ld main.o`, `./a.out`)
@LIA.nim:               @LIA.eval(`["main.nim"]`, `nim c main.nim`, `./main`)
@LIA.perl:              @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl main.pl`)
@LIA.perl_withShell:    @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl -d main.pl`)
@LIA.python:            @LIA.python3
@LIA.python_withShell:  @LIA.python3_withShell
@LIA.python2:           @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 main.pyc`)
@LIA.python2_withShell: @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 -i main.pyc`)
@LIA.python3:           @LIA.eval(`["main.py"]`, `none`, `python3 main.py`)
@LIA.python3_withShell: @LIA.eval(`["main.py"]`, `none`, `python3 -i main.py`)
@LIA.r:                 @LIA.eval(`["main.R"]`, `none`, `Rscript main.R`)
@LIA.r_withShell:       @LIA.eval(`["main.R"]`, `none`, `sh -c "cat main.R - | R --interactive"`)
@LIA.ruby:              @LIA.eval(`["main.rb"]`, `none`, `ruby main.rb`)
@LIA.ruby_withShell:    @LIA.eval(`["main.rb"]`, `none`, `irb --nomultiline -r ./main.rb`)
@LIA.rust:              @LIA.eval(`["main.rs"]`, `rustc main.rs`, `./main`)
@LIA.v:                 @LIA.eval(`["main.v"]`, `v main.v`, `./main`)
@LIA.v_withShell:       @LIA.eval(`["main.v"]`, `none`, `sh -c "cat main.v - | v repl"`)
@LIA.zig:               @LIA.eval(`["main.zig"]`, `zig build-exe ./main.zig -O ReleaseSmall`, `./main`)

@LIA.dotnet
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
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
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)
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
                    console.html("<video title='" + msg.videos[i].file + "' src='" + msg.videos[i].data + "'></video>")
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
@LIA.eval(`["main.asm"]`, `nasm  -felf64 main.asm && ld main.o`, `./a.out`)

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
    <TargetFramework>net6.0</TargetFramework>
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
@LIA.eval(`["main.exs"]`, `none`, `iex main.exs`)

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
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)

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

### Nim : `@LIA.nim`

Nim is a statically typed, compiled programming language that combines the performance of C with the expressiveness of modern languages like Python. First released in 2008, Nim is known for its simplicity, efficiency, and flexibility, making it suitable for systems programming, web development, and scientific computing. Nim features a powerful metaprogramming system, automatic memory management, and a syntax that is easy to read and write. It compiles to C, C++, and JavaScript, enabling cross-platform development with high performance. The backend here uses the Nim compiler to execute Nim code, ensuring efficient and optimized output.

For more information, you can visit the [Nim programming language Wikipedia page](https://en.wikipedia.org/wiki/Nim_%28programming_language%29).

---

```nim
echo "Hello World"
```
@LIA.nim

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

### V : `@LIA.v`

V is a statically typed, compiled programming language designed for simplicity, performance, and safety. It was created by Alexander Medvednikov and first released in 2020. V aims to be a lightweight language that is easy to learn and use, with a syntax that is straightforward and similar to Go and Python. It focuses on providing a high level of efficiency while maintaining readability and ease of use. V supports both procedural and functional programming paradigms and is designed to compile to native machine code, resulting in fast execution and minimal runtime dependencies. The backend here uses the V compiler to compile V code, ensuring efficient and reliable performance.

For more information, you can visit the [V programming language Wikipedia page](https://en.wikipedia.org/wiki/V_%28programming_language%29).

---

```v
println("Hello World")
```
@LIA.v_withShell

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
//window.CodeRunner.init("ws://127.0.0.1:8000/")
window.CodeRunner.init("wss://ancient-hollows-41316.herokuapp.com/")
@end


@LIA.ada:               @LIA.eval(`["main.ada"]`, `gnatmake main.ada`, `./main`)
@LIA.c:                 @LIA.eval(`["main.c"]`, `gcc -Wall main.c -o a.out`, `./a.out`)
@LIA.clojure:           @LIA.eval(`["main.clj"]`, `none`, `clojure -M main.clj`)
@LIA.clojure_withShell: @LIA.eval(`["main.clj"]`, `none`, `clojure -M -i main.clj -r`)
@LIA.cpp:               @LIA.eval(`["main.cpp"]`, `g++ main.cpp -o a.out`, `./a.out`)
@LIA.elixir:            @LIA.eval(`["main.exs"]`, `none`, `elixir main.exs`)
@LIA.elixir_withShell:  @LIA.eval(`["main.exs"]`, `none`, `iex main.exs`)
@LIA.go:                @LIA.eval(`["main.go"]`, `go build main.go`, `./main`)
@LIA.haskell:           @LIA.eval(`["main.hs"]`, `ghc main.hs -o main`, `./main`)
@LIA.haskell_withShell: @LIA.eval(`["main.hs"]`, `none`, `ghci main.hs`)
@LIA.java:              @LIA.eval(`["@0.java"]`, `javac @0.java`, `java @0`)
@LIA.julia:             @LIA.eval(`["main.jl"]`, `none`, `julia main.jl`)
@LIA.julia_withShell:   @LIA.eval(`["main.jl"]`, `none`, `julia -i main.jl`)
@LIA.mono:              @LIA.eval(`["main.cs"]`, `mcs main.cs`, `mono main.exe`)
@LIA.nasm:              @LIA.eval(`["main.asm"]`, `nasm -felf64 main.asm && ld main.o`, `./a.out`)
@LIA.nim:               @LIA.eval(`["main.nim"]`, `nim c main.nim`, `./main`)
@LIA.perl:              @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl main.pl`)
@LIA.perl_withShell:    @LIA.eval(`["main.pl"]`, `perl -c main.pl`, `perl -d main.pl`)
@LIA.python:            @LIA.python3
@LIA.python_withShell:  @LIA.python3_withShell
@LIA.python2:           @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 main.pyc`)
@LIA.python2_withShell: @LIA.eval(`["main.py"]`, `python2.7 -m compileall .`, `python2.7 -i main.pyc`)
@LIA.python3:           @LIA.eval(`["main.py"]`, `none`, `python3 main.py`)
@LIA.python3_withShell: @LIA.eval(`["main.py"]`, `none`, `python3 -i main.py`)
@LIA.r:                 @LIA.eval(`["main.R"]`, `none`, `Rscript main.R`)
@LIA.r_withShell:       @LIA.eval(`["main.R"]`, `none`, `sh -c "cat main.R - | R --interactive"`)
@LIA.ruby:              @LIA.eval(`["main.rb"]`, `none`, `ruby main.rb`)
@LIA.ruby_withShell:    @LIA.eval(`["main.rb"]`, `none`, `irb --nomultiline -r ./main.rb`)
@LIA.rust:              @LIA.eval(`["main.rs"]`, `rustc main.rs`, `./main`)
@LIA.v:                 @LIA.eval(`["main.v"]`, `v main.v`, `./main`)
@LIA.v_withShell:       @LIA.eval(`["main.v"]`, `none`, `sh -c "cat main.v - | v repl"`)
@LIA.zig:               @LIA.eval(`["main.zig"]`, `zig build-exe ./main.zig -O ReleaseSmall`, `./main`)

@LIA.dotnet
```xml    -project.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
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
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
```
@LIA.eval(`["Program.fs", "project.fsproj"]`, `dotnet build -nologo`, `dotnet run`)
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
