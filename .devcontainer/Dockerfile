# Start from the official OpenLane image
FROM efabless/openlane:v0.21

# Switch to root to install system packages and manage files
USER root

# Install essential packages for the GUI, VNC, and for handling archives
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xvfb \
    xfce4 \
    xfce4-goodies \
    firefox \
    wget \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN pip3 install --no-cache-dir novnc websockify

# Create Desktop directory for the openlane user
RUN mkdir -p /home/openlane/Desktop && \
    chown -R 1000:1000 /home/openlane/Desktop

# --- DOWNLOAD AND EXTRACT work.zip TO DESKTOP ---
# Download the work.zip file from your DigitalOcean space
RUN wget -O /tmp/work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"

# Extract the zip file directly to the Desktop
RUN unzip /tmp/work.zip -d /home/openlane/Desktop/ && \
    rm /tmp/work.zip

# Set the ownership of the extracted files to the 'openlane' user
RUN chown -R 1000:1000 /home/openlane/Desktop/work

# Switch back to the non-root 'openlane' user for security
USER 1000

# Set the working directory to home (traditional Linux location)
WORKDIR /home/openlane

# Set the PDK_ROOT environment variable to point to the PDK inside the extracted work.zip
ENV PDK_ROOT=/home/openlane/Desktop/work/tools/openlane_working_dir/pdks

# Add PDK_ROOT to bashrc for persistence
RUN echo "export PDK_ROOT=/home/openlane/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
