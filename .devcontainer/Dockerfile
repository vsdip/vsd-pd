# Start from Ubuntu 20.04 with root user for installation
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install ALL packages as ROOT (this is crucial)
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
    tcl \
    tcllib \
    tcl-trf \
    tclx \
    tk \
    locales \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Python packages
RUN pip3 install pandas numpy

# Create user and switch to it AFTER installation
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the user
USER vscode
WORKDIR /home/vscode

# Set up the environment
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Create Desktop directory
RUN mkdir -p /home/vscode/Desktop
