#!/bin/bash

echo "Installing latest OpenLane..."

# Install latest OpenLane
cd /home/vscode
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane

# Create Python virtual environment
python3 -m venv openlane_venv
source openlane_venv/bin/activate

# Install OpenLane
pip3 install -e .

# Install all tools (OpenROAD, Yosys, Magic, etc.)
echo "Installing EDA tools via 'make merge'..."
make merge

# Set up environment
echo "export OPENLANE_ROOT=/home/vscode/OpenLane" >> ~/.bashrc
echo "export PDK_ROOT=/home/vscode/OpenLane/pdks" >> ~/.bashrc
echo "source /home/vscode/OpenLane/openlane_venv/bin/activate" >> ~/.bashrc

# Create desktop shortcut
mkdir -p /home/vscode/Desktop
cat > /home/vscode/Desktop/OpenLane.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenLane
Comment=OpenLane Digital ASIC Flow
Exec=xfce4-terminal -e "cd /home/vscode/OpenLane && bash -c 'source openlane_venv/bin/activate; bash'"
Icon=folder
Terminal=false
StartupNotify=true
EOF

chmod +x /home/vscode/Desktop/OpenLane.desktop

# Start VNC services
echo "Starting VNC desktop..."
Xvfb :1 -screen 0 1440x900x24 &
export DISPLAY=:1
sleep 2

# Start desktop environment
dbus-daemon --session --fork
startxfce4 &
x11vnc -display :1 -forever -shared -nopw -bg
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "=========================================="
echo "🎉 LATEST OPENLANE INSTALLED!"
echo "=========================================="
echo "OpenLane location: /home/vscode/OpenLane"
echo "VNC Desktop: Port 6080"
echo ""
echo "Quick start:"
echo "1. Open desktop via port 6080"
echo "2. Click OpenLane desktop shortcut"
echo "3. Run: ./flow.tcl -design spm"
echo "=========================================="

# Keep services running
tail -f /dev/null
