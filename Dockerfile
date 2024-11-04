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
