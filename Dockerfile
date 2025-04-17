FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list && \
    apt-get update

RUN apt-get install -y --no-install-recommends firejail

RUN apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    git \
    make \
    cmake \
    software-properties-common \
    tar \
    xz-utils \
    python3-dev \
    pkg-config \
    build-essential \
    # C/C++
    gcc-12 \
    gcc-12-base \
    g++-12 \
    libstdc++-12-dev \
    libstdc++-12-doc \
    # Python
    python2.7 \
    # Python3
    python3 \
    python3-pip \
    ninja-build \
    ffmpeg \
    libcairo2-dev \
    libpango1.0-dev \
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
    npm \
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
    musl \
    # R
    r-base \
    r-cran-car \
    r-cran-mapdata \
    r-cran-reshape

##################################################################################
### JAVA
#RUN apt-get install -y default-jdk
RUN curl -O https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.deb \
    && dpkg -i jdk-24_linux-x64_bin.deb \
    && rm jdk-24_linux-x64_bin.deb

### Julia
RUN curl -fsSL https://install.julialang.org | sh -s -- -y \
    && echo 'export PATH="$PATH:/root/.juliaup/bin"' >> /etc/profile \
    && echo 'export PATH="$PATH:/root/.juliaup/bin"' >> /root/.bashrc \
    && ln -s /root/.juliaup/bin/julia /usr/local/bin/julia

### Zig
RUN curl -fLO https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz \
    && tar -xf zig-linux-x86_64-0.14.0.tar.xz \
    && rm zig-linux-x86_64-0.14.0.tar.xz \
    && mv zig-linux-x86_64-0.14.0/ /opt/ \
    && ln -s /opt/zig-linux-x86_64-0.14.0/zig /usr/local/bin/zig

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
# Install the latest version of meson
RUN pip3 install --upgrade meson \
    && pip3 install \
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

# Solidity
RUN npm install --global solc

# Q# (Quantum)
RUN dotnet tool install -g Microsoft.Quantum.IQSharp

# SelectScript
RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
    -o /usr/local/bin/lein \
    && chmod +x /usr/local/bin/lein \
    && git clone --recursive  https://github.com/andre-dietrich/SelectScriptC.git \
    && cd SelectScriptC \
    && make \
    && make install

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libobjc-12-dev \
    gnustep \
    gnustep-devel \
    libgnustep-base-dev \
    libblocksruntime-dev \
    clang

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

# Modula 2 requirement
ENV GM2PATH=/usr/share/gm2

RUN mv /usr/bin/gm2 /usr/bin/gm2.real && \
    printf '#!/bin/sh\nexec /usr/bin/gm2.real -g -I. -flibs=pim,iso,cor "$@"\n' > /usr/bin/gm2 && \
    chmod +x /usr/bin/gm2 

# Create Objective-C compiler script with GNUstep configuration
RUN printf '#!/bin/bash\n\
    if [ $# -lt 1 ]; then\n\
    echo "Usage: gobjc source_file [output_name]"\n\
    exit 1\n\
    fi\n\
    \n\
    SOURCEFILE="$1"\n\
    FILENAME=$(basename -- "$SOURCEFILE")\n\
    BASENAME="${FILENAME%%.*}"\n\
    \n\
    # Use second argument as output name if provided, otherwise use source basename\n\
    OUTPUT="${2:-$BASENAME}"\n\
    \n\
    . /usr/share/GNUstep/Makefiles/GNUstep.sh\n\
    gcc -std=gnu11 -x objective-c $(gnustep-config --objc-flags) -o "$OUTPUT" "$SOURCEFILE" $(gnustep-config --base-libs)\n\
    ' > /usr/local/bin/gobjc && \
    chmod +x /usr/local/bin/gobjc

EXPOSE 4000

ENTRYPOINT ["python3","-m","server","--host","0.0.0.0","--port","4000"]
