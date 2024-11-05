FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    curl \
    git \
    firejail

##################################################################################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make

### C
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gcc-12 \
    gcc-12-base

### C++
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y g++-12 \
    libstdc++-12-dev \
    libstdc++-12-doc

### MONO
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mono-complete mono-mcs

### GO
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y golang-go

### RUST
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y rustc

### JAVA
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk
RUN curl -O https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.deb \
    && dpkg -i jdk-23_linux-x64_bin.deb \
    && rm jdk-23_linux-x64_bin.deb

### Haskell
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ghc

### .NET 6
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dotnet6 apt-transport-https

### R
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-car
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-mapdata
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-reshape

### Julia
RUN curl -fsSL https://install.julialang.org | sh -s -- -y

### Zig
RUN curl -fLO https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
    && tar -xf zig-linux-x86_64-0.13.0.tar.xz \
    && rm zig-linux-x86_64-0.13.0.tar.xz \
    && mv zig-linux-x86_64-0.13.0/ /opt/ \
    && ln -s /opt/zig-linux-x86_64-0.13.0/zig /usr/local/bin/zig

### Nim
RUN curl -O https://nim-lang.org/choosenim/init.sh -sSf \
    && sh init.sh -y \
    && ln -s /root/.nimble/bin/nim /usr/local/bin/nim

### Nasm Assembly
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nasm

### V-lang
RUN git clone https://github.com/vlang/v
RUN cd v &&\
    make && \
    ./v symlink

### Python2
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python2.7

### Python3
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
RUN DEBIAN_FRONTEND=noninteractive pip3 install \
    matplotlib \
    numpy \
    opencv-python opencv-contrib-python \
    pyarrow \
    pandas \
    scipy \
    sympy \
    pyyaml

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ffmpeg \
    libcairo2-dev \
    libpango1.0-dev
RUN DEBIAN_FRONTEND=noninteractive pip3 install \
    pycairo \
    manim

### Perl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y perl

### Ruby
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ruby-full

### Clojure
RUN curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
    && chmod +x linux-install.sh \
    && ./linux-install.sh \
    && rm linux-install.sh \
    && clojure -e "(println \"First run clojure to install libs...\")"

### ADA
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnat-12

### Elixir
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y erlang-dev elixir

### Latex
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y texlive-latex-extra

### COBOL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnucobol

### Fortran
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gfortran

### Algol
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y algol68g

### APL
RUN curl -O https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=19.0/linux_64_19.0.50027_unicode.x86_64.deb \
    && dpkg -i linux_64_19.0.50027_unicode.x86_64.deb \
    && rm linux_64_19.0.50027_unicode.x86_64.deb

### Prolog
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y swi-prolog

### Forth
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gforth

### Pascal
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y fpc


### OCaml
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ocaml

### Scheme
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y guile-3.0

### Smalltalk
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnu-smalltalk

### Prolog
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y swi-prolog

### Groovy
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y groovy

### Scala
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y scala

### Racket
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y racket

### Tcl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tcl

### IO
# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libffi-dev \
    cmake \
    libpcre3-dev \
    libxml2-dev \
    libssl-dev \
    zlib1g-dev \
    git

# Clone the Io language repository with submodules
RUN git clone --recurse-submodules https://github.com/IoLanguage/io.git && \
    cd io && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf io

### Kotlin
# Install SDKMAN
#RUN curl -s "https://get.sdkman.io" | bash

# Install Kotlin and set up environment
#RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin && sdk install java"

# Set environment variables for SDKMAN in Docker
#ENV SDKMAN_DIR="/root/.sdkman"
#ENV PATH="$SDKMAN_DIR/bin:$SDKMAN_DIR/candidates/kotlin/current/bin:$PATH"

# Verify installation
#RUN kotlin -version

### PostScript
#RUN sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list && \
#    DEBIAN_FRONTEND=noninteractive apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y ghostscript


### Lua
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lua5.4

### D
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gdc

### Verilog
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y iverilog

### VHDL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ghdl

### Octave
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y octave

### COQ
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y coq

#############################################################################################
COPY . /coderunner
WORKDIR "/coderunner"

RUN pip3 install -r requirements.txt

RUN chmod u+s /usr/bin/firejail

# For some reasons firejail needs to be run multiple times to work
RUN firejail || true
RUN firejail || true
RUN firejail || true
RUN firejail || true
RUN firejail || true

RUN firejail || true
RUN firejail || true
RUN firejail || true
RUN firejail || true
RUN firejail || true

#EXPOSE 8000

CMD python3 -m server --host 0.0.0.0 --port $PORT
