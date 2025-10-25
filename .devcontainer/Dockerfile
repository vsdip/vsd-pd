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
    magic ngspice gtkwave verilator iverilog \
    # Build tools
    build-essential cmake clang tcl-dev git curl ca-certificates gnupg \
    # Dependencies
    tcl tcllib tcl-trf tclx tk locales sudo \
    perl libfile-which-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install COMPATIBLE Python packages (fix version conflicts)
RUN pip3 install numpy==1.21.0 pandas==1.3.0 matplotlib jinja2 XlsxWriter

# 1) Yosys, etc. via OSS CAD Suite (has yosys -eqy)
RUN set -eux; \
  curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-10-03/oss-cad-suite-linux-x64-20241003.tgz \
    -o /tmp/oss-cad.tgz; \
  mkdir -p /opt && tar -xzf /tmp/oss-cad.tgz -C /opt; \
  ln -s /opt/oss-cad-suite /opt/oss-cad; \
  rm /tmp/oss-cad.tgz
ENV PATH="/opt/oss-cad/bin:${PATH}"

# 2) KLayout (use package matching your Ubuntu)
#    If you already have it elsewhere, you can skip this block.
RUN set -eux; \
  curl -L -o /tmp/klayout.deb \
    https://www.klayout.org/downloads/Ubuntu-22.04/klayout_0.30.3-1_amd64.deb; \
  apt-get update && apt-get install -y --no-install-recommends /tmp/klayout.deb; \
  rm -rf /var/lib/apt/lists/* /tmp/klayout.deb

# Install OpenROAD from pre-built binary (simplest approach)
RUN apt update && apt install -y wget && \
    wget https://github.com/Precision-Innovations/OpenROAD/releases/download/2024-12-14/openroad_2.0-17598-ga008522d8_amd64-ubuntu-20.04.deb -O /tmp/openroad.deb && \
    apt install -y ./tmp/openroad.deb && \
    rm /tmp/openroad.deb && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Verify installation
RUN which openroad && openroad -version

# 4) ORFS (no submodules; we’re using prebuilt tools)
RUN git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts /opt/orfs
WORKDIR /opt/orfs

# 5) Wire ORFS to our binaries (per docs)
ENV OPENROAD_EXE="$(which openroad)" \
    YOSYS_EXE="$(which yosys)"

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
