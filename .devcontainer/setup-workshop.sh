#!/bin/bash

echo "Setting up exact OpenLane v0.21 workshop environment..."

# Download and extract work.zip to Desktop
cd /home/vscode/Desktop
echo "Downloading workshop files..."
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Set up environment variables
echo "export PDK_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
echo "export OPENLANE_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/openlane" >> ~/.bashrc
echo "cd /home/vscode/Desktop/work" >> ~/.bashrc

# Create desktop shortcut
cat > /home/vscode/Desktop/Open-Workshop.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Open Workshop
Comment=Open the workshop directory
Exec=xfce4-terminal -e "cd /home/vscode/Desktop/work && bash"
Icon=folder
Terminal=false
StartupNotify=true
EOF

chmod +x /home/vscode/Desktop/Open-Workshop.desktop

# Start VNC services
echo "Starting VNC services..."
Xvfb :1 -screen 0 1440x900x24 &
export DISPLAY=:1
sleep 2
startxfce4 &
x11vnc -display :1 -forever -shared -nopw -bg
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "=========================================="
echo "Workshop environment ready!"
echo "1. Access desktop via Port 6080"
echo "2. Your work folder is on the Desktop"
echo "3. Open terminal and run OpenLane commands"
echo "4. All tools are pre-configured as in your original workshop"
echo "=========================================="
