FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list && \
    apt-get update

RUN apt-get install -y --no-install-recommends firejail

RUN apt-get install -y \
    apt-utils \
    curl \
    git \
    make \
    cmake \
    # C/C++
    gcc-12 \
    gcc-12-base \
    g++-12 \
    libstdc++-12-dev \
    libstdc++-12-doc \
    # Python
    python2.7 \
    python3 \
    python3-pip \
    # MONO
    mono-complete \
    mono-mcs \
    # GO
    golang-go \
    # RUST
    rustc \
    # Haskell
    ghc \
    # .NET 8
    dotnet8 apt-transport-https \
    # Perl
    perl \
    # Ruby
    ruby-full \
    # Assembly
    nasm \
    # ADA
    gnat-12 \
    # Elixir
    erlang-dev elixir \
    # Latex 
    texlive-latex-extra \
    # COBOL
    gnucobol \
    # Fortran
    gfortran \
    # Algol
    algol68g \
    # Prolog
    swi-prolog \
    # Forth
    gforth \
    # Pascal
    fpc \
    # OCaml
    ocaml \
    # Scheme
    guile-3.0 \
    # Smalltalk
    gnu-smalltalk \
    # Groovy
    groovy \
    # Scala
    scala \
    # Racket
    racket \
    # Tcl
    tcl \
    # PostScript
    ghostscript \
    # Lua
    lua5.4 \
    # D
    gdc \
    # Verilog
    iverilog \
    # VHDL
    ghdl \
    # Octave
    octave \
    # COQ
    coq \
    # VALA
    valac \
    # Standard ML
    smlnj \
    # Kotlin
    kotlin \
    # PHP
    php \
    # NodeJS
    nodejs \
    # AWK
    gawk \
    # REXX
    regina-rexx \
    # Haxe
    haxe \
    # Modula-2
    gm2 \
    libgm2-12-dev \
    # Objective-C
    gobjc \
    # Objective-C++
    gobjc++ \
    # Basic
    bwbasic \
    # Inform
    inform \
    frotz \
    ncurses-bin \
    musl

##################################################################################
RUN apt-get install -y make

### JAVA
#RUN apt-get install -y default-jdk
RUN curl -O https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.deb \
    && dpkg -i jdk-24_linux-x64_bin.deb \
    && rm jdk-24_linux-x64_bin.deb

### R
RUN apt-get install -y r-base \
    r-cran-car \
    r-cran-mapdata \
    r-cran-reshape

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

### V-lang
RUN git clone https://github.com/vlang/v
RUN cd v &&\
    make && \
    ./v symlink

### Python3
RUN apt-get install -y \
    ninja-build \
    ffmpeg \
    libcairo2-dev \
    libpango1.0-dev

# Install the latest version of meson
RUN pip3 install --upgrade meson

RUN pip3 install \
    matplotlib \
    numpy \
    opencv-python opencv-contrib-python \
    pyarrow \
    pandas \
    scipy \
    sympy \
    pyyaml \
    pycairo \
    manim

### Clojure
RUN curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
    && chmod +x linux-install.sh \
    && ./linux-install.sh \
    && rm linux-install.sh \
    && clojure -e "(println \"First run clojure to install libs...\")"

### APL
RUN curl -O https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=19.0/linux_64_19.0.50027_unicode.x86_64.deb \
    && dpkg -i linux_64_19.0.50027_unicode.x86_64.deb \
    && rm linux_64_19.0.50027_unicode.x86_64.deb


### IO
# Install dependencies
RUN apt-get install -y libffi-dev \
    libpcre3-dev \
    libxml2-dev \
    libssl-dev \
    zlib1g-dev

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

# Solidity
RUN add-apt-repository -y ppa:ethereum/ethereum \
    && apt-get update \
    && apt-get install -y solc

# Q# (Quantum)
#RUN dotnet tool install -g Microsoft.Quantum.IQSharp

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

EXPOSE 4000

CMD python3 -m server --host 0.0.0.0 --port $PORT
