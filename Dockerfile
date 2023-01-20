FROM ubuntu:kinetic

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gcc
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y g++
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
RUN DEBIAN_FRONTEND=noninteractive pip3 install matplotlib \
    numpy \
    pandas

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python2.7

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y firejail

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mono-complete mono-mcs

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y golang-go

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y rustc

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ghc

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dotnet6 apt-transport-https

# R
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-car
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-mapdata
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-cran-reshape

RUN curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz \
    && tar -xvzf julia-1.8.2-linux-x86_64.tar.gz \
    && rm julia-1.8.2-linux-x86_64.tar.gz \
    && mv julia-1.8.2/ /opt/ \
    && ln -s /opt/julia-1.8.2/bin/julia /usr/local/bin/julia

RUN curl -O https://download.clojure.org/install/linux-install-1.11.1.1165.sh \
    && chmod +x linux-install-1.11.1.1165.sh \
    && ./linux-install-1.11.1.1165.sh \
    && rm linux-install-1.11.1.1165.sh \
    && clojure

RUN curl -O https://ziglang.org/builds/zig-linux-x86_64-0.10.0-dev.4442+ce3ffa5e1.tar.xz \
    && tar -xf zig-linux-x86_64-0.10.0-dev.4442+ce3ffa5e1.tar.xz \
    && rm zig-linux-x86_64-0.10.0-dev.4442+ce3ffa5e1.tar.xz \
    && mv zig-linux-x86_64-0.10.0-dev.4442+ce3ffa5e1/ /opt/ \
    && ln -s /opt/zig-linux-x86_64-0.10.0-dev.4442+ce3ffa5e1/zig /usr/local/bin/zig

RUN curl -O https://nim-lang.org/choosenim/init.sh -sSf \
    && sh init.sh -y \
    && ln -s /root/.nimble/bin/nim /usr/local/bin/nim

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nasm

RUN git clone https://github.com/vlang/v
RUN cd v &&\
    make && \
    ./v symlink

COPY . /coderunner
WORKDIR "/coderunner"

RUN pip3 install -r requirements.txt

#EXPOSE 8000

CMD python3 -m server --host 0.0.0.0 --port $PORT
