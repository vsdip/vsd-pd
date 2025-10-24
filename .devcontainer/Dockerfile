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
    magic ngspice gtkwave verilator iverilog klayout \
    # Build tools
    build-essential cmake clang tcl-dev git curl ca-certificates gnupg \
    # Dependencies
    tcl tcllib tcl-trf tclx tk locales sudo \
    perl libfile-which-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install COMPATIBLE Python packages (fix version conflicts)
RUN pip3 install numpy==1.21.0 pandas==1.3.0 matplotlib jinja2 XlsxWriter


# Preinstall OSS CAD Suite (has yosys, so skip -eqy)
RUN set -eux; \
    curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-10-03/oss-cad-suite-linux-x64-20241003.tgz \
    -o /tmp/oss-cad.tgz && \
    mkdir -p /opt && tar -xzf /tmp/oss-cad.tgz -C /opt && \
    ln -s /opt/oss-cad-suite /opt/oss-cad && \
    rm /tmp/oss-cad.tgz
ENV PATH="/opt/oss-cad/bin:${PATH}"

# Install only necessary build dependencies manually
RUN apt update && apt install -y \
    git build-essential cmake \
    tcl-dev libboost-all-dev libeigen3-dev \
    libspdlog-dev libyaml-cpp-dev \
    qtbase5-dev libqt5charts5-dev \
    && apt clean && rm -rf /var/lib/apt/lists/*

# SWIG 4.x + headers needed by OpenROAD’s bindings
RUN apt-get update && apt-get install -y --no-install-recommends \
    swig4.0 tcl-dev python3-dev cmake g++ make && \
    update-alternatives --install /usr/bin/swig swig /usr/bin/swig4.0 50 && \
    rm -rf /var/lib/apt/lists/*

# (optional but helps CMake locate SWIG cleanly)
ENV SWIG_EXECUTABLE=/usr/bin/swig \
    SWIG_DIR=/usr/share/swig/4.0

# Build OpenROAD only (skip dependency installer since we have OSS CAD)
RUN cd /tmp && \
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts && \
    cd OpenROAD-flow-scripts && \
    # Skip -all since we have OSS CAD Suite, just build OpenROAD
    MAKEJOBS=2 ./build_openroad.sh --local && \
    cd /tmp && rm -rf OpenROAD-flow-scripts



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
