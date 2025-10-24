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


# Install OpenROAD dependencies using their official script
RUN apt update && apt install -y \
    wget git build-essential cmake curl unzip && \
    cd /tmp && \
    wget https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD/main/etc/DependencyInstaller.sh && \
    chmod +x DependencyInstaller.sh && \
    ./DependencyInstaller.sh -base -common && \
    rm DependencyInstaller.sh

# Now install the OpenROAD .deb package (dependencies should be satisfied)
RUN cd /tmp && \
    wget https://github.com/Precision-Innovations/OpenROAD/releases/download/latest-bin/openroad_2.0_amd64-ubuntu20.04.deb && \
    apt install -y ./openroad_2.0_amd64-ubuntu20.04.deb && \
    rm openroad_2.0_amd64-ubuntu20.04.deb

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
