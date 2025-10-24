FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install ALL required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Core system
    wget unzip git make python3 python3-pip \
    # Desktop environment
    xvfb xfce4 xfce4-session xfce4-panel xfdesktop4 xfwm4 \
    xfce4-terminal thunar dbus-x11 x11vnc novnc websockify \
    # EDA tools available in Ubuntu
    yosys magic ngspice gtkwave verilator iverilog klayout \
    # Build tools
    build-essential cmake clang tcl-dev git \
    # Dependencies
    tcl tcllib tcl-trf tclx tk locales sudo \
    perl libfile-which-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install COMPATIBLE Python packages (fix version conflicts)
RUN pip3 install numpy==1.21.0 pandas==1.3.0 matplotlib jinja2 XlsxWriter


# Install all build dependencies including GTest
RUN apt update && apt install -y \
    git build-essential cmake \
    tcl-dev tk-dev swig \
    bison flex \
    libboost-all-dev \
    libspdlog-dev \
    libeigen3-dev \
    libz-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libpcre2-dev \
    libyaml-cpp-dev \
    qtbase5-dev \
    libqt5charts5-dev \
    libgtest-dev \
    googletest \
    && rm -rf /var/lib/apt/lists/*

# Build and install GTest
RUN cd /usr/src/googletest && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# Install OpenROAD via conda (most reliable method)
RUN apt update && apt install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Install OpenROAD via conda
RUN /opt/conda/bin/conda install -c litex-hub openroad -y && \
    ln -s /opt/conda/bin/* /usr/local/bin/

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8

# Create user
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
WORKDIR /home/vscode
RUN mkdir -p /home/vscode/Desktop
