#!/bin/bash

echo "Installing latest OpenLane with automated tool setup..."

# Install latest OpenLane
cd /home/vscode
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane

# Create Python virtual environment
python3 -m venv openlane_venv
source openlane_venv/bin/activate

# Install OpenLane and required Python packages
pip3 install -e .
pip3 install pandas numpy matplotlib jinja2 XlsxWriter

# This ONE command installs ALL tools including OpenROAD
echo "Running 'make merge' - this will install OpenROAD, Yosys, Magic, and all other tools..."
make merge

# Verify Python packages are available
echo "Verifying Python packages..."
python3 -c "import pandas, numpy, matplotlib, jinja2, XlsxWriter; print('✅ All Python packages installed successfully')"

# Set up environment
echo "export OPENLANE_ROOT=/home/vscode/OpenLane" >> ~/.bashrc
echo "export PDK_ROOT=/home/vscode/OpenLane/pdks" >> ~/.bashrc
echo "source /home/vscode/OpenLane/openlane_venv/bin/activate" >> ~/.bashrc

# Download your workshop files
cd /home/vscode/Desktop
echo "Downloading your workshop files..."
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Use your PDK if you prefer
if [ -d "/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" ]; then
    echo "export PDK_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
fi

# Create desktop shortcuts
cat > /home/vscode/Desktop/OpenLane-Latest.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenLane (Latest)
Comment=Latest OpenLane with auto-installed tools
Exec=xfce4-terminal -e "cd /home/vscode/OpenLane && bash"
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

echo "=========================================="
echo "🎉 OPENLANE INSTALLATION COMPLETE!"
echo "=========================================="
echo "✅ OpenLane installed: /home/vscode/OpenLane"
echo "✅ OpenROAD auto-installed via 'make merge'"
echo "✅ All EDA tools installed and compatible"
echo "✅ Python packages: pandas, numpy, matplotlib, jinja2, XlsxWriter"
echo "✅ Your workshop files: /home/vscode/Desktop/work"
echo ""
echo "📋 VERIFICATION:"
echo "cd /home/vscode/OpenLane"
echo "./flow.tcl -design spm"
echo "=========================================="

while true; do sleep 60; done
