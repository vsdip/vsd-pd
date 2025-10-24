#!/bin/bash

echo "Setting up OpenLane workshop environment..."

# Download and extract work.zip to Desktop
cd /home/vscode/Desktop
echo "Downloading workshop files..."
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Set environment variables
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
dbus-daemon --session --fork
startxfce4 &
x11vnc -display :1 -forever -shared -nopw -bg
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "=========================================="
echo "WORKSHOP SETUP COMPLETE!"
echo "=========================================="
echo "Your workshop files are on the Desktop"
echo "Access the desktop via port 6080"
echo ""
echo "To run OpenLane:"
echo "cd ~/Desktop/work/tools/openlane_working_dir/openlane"
echo "./flow.tcl -interactive"
echo "prep -design spm"
echo "=========================================="

# Keep services running
tail -f /dev/null
