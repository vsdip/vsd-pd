# Start from the official OpenLane image
FROM efabless/openlane:v0.21

# Switch to root to install system packages
USER root

# Install essential packages for the GUI and VNC
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xvfb \
    xfce4 \
    xfce4-goodies \
    firefox \
    geany \
    vim \
    git \
    python3 \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN pip3 install --no-cache-dir novnc websockify

# Create a directory for our setup scripts and copy them
WORKDIR /opt/setup
COPY scripts/ ./scripts/
RUN chmod +x /opt/setup/scripts/*.sh

# Create the workspace directory and set appropriate permissions
RUN mkdir -p /workspace && chown -R 1000:1000 /workspace

# Switch back to the non-root 'openlane' user for security
USER 1000

# Set the working directory
WORKDIR /workspace
