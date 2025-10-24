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

# Install Python packages that OpenLane needs
RUN pip3 install pandas numpy matplotlib jinja2 XlsxWriter

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
