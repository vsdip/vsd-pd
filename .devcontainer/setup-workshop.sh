#!/bin/bash

echo "Setting up latest OpenLane with your workshop files..."

# Install latest OpenLane
cd /home/vscode
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane

# Create Python virtual environment
python3 -m venv openlane_venv
source openlane_venv/bin/activate

# Install OpenLane
pip3 install -e .
make merge

# Download your workshop files
cd /home/vscode/Desktop
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Use your existing PDK
if [ -d "/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" ]; then
    echo "export PDK_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
    echo "export OPENLANE_ROOT=/home/vscode/OpenLane" >> ~/.bashrc
fi

# Create both shortcuts
cat > /home/vscode/Desktop/OpenLane-New.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenLane (Latest)
Comment=Latest OpenLane installation
Exec=xfce4-terminal -e "cd /home/vscode/OpenLane && bash"
Icon=folder
Terminal=false
StartupNotify=true
EOF

cat > /home/vscode/Desktop/Workshop-Files.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Workshop Files
Comment=Your workshop designs and files
Exec=xfce4-terminal -e "cd /home/vscode/Desktop/work && bash"
Icon=folder
Terminal=false
StartupNotify=true
EOF

chmod +x /home/vscode/Desktop/*.desktop

# Start VNC services
Xvfb :1 -screen 0 1440x900x24 &
export DISPLAY=:1
sleep 2
startxfce4 &
x11vnc -display :1 -forever -shared -nopw -bg
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "Setup complete! You have:"
echo "- Latest OpenLane in /home/vscode/OpenLane"
echo "- Your workshop files in /home/vscode/Desktop/work"
echo "- Two desktop shortcuts for easy access"

while true; do sleep 60; done
