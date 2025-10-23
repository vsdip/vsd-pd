# Start from Ubuntu 20.04 (which has apt-get and matches OpenLane requirements)
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including desktop environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    git \
    make \
    python3 \
    python3-pip \
    python3-venv \
    xvfb \
    xfce4 \
    xfce4-terminal \
    firefox \
    x11vnc \
    novnc \
    websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user for the workshop
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the user
USER vscode
WORKDIR /home/vscode

# Clone and install OpenLane v0.21
# Remove the git clone OpenLane section and replace with:

# Install OpenLane dependencies natively
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tcl \
    tcllib \
    tcl-trf \
    tclx \
    tk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install specific Tcl packages that OpenLane needs
RUN pip3 install --no-cache-dir \
    click \
    pandas \
    numpy \
    pyyaml

# Set up the OpenLane environment
ENV OPENLANE_ROOT=/home/vscode/OpenLane
ENV PATH="${OPENLANE_ROOT}/tools/OpenROAD:${OPENLANE_ROOT}/tools/yosys:${PATH}"

# Create Desktop directory
RUN mkdir -p /home/vscode/Desktop
