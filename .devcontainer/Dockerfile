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


# Install build dependencies for OpenROAD
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
    && rm -rf /var/lib/apt/lists/*

# Clone and build OpenROAD with specific working commit
RUN cd /tmp && \
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git && \
    cd OpenROAD && \
    # Use a known working commit
    git checkout a1fd7d3 && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && \
    rm -rf OpenROAD

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
