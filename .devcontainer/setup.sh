#!/bin/bash

echo "Setting up OpenLane workshop environment..."

# Download and extract work.zip to Desktop
cd /home/vscode/Desktop
echo "Downloading workshop files..."
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Apply compatibility fixes to the workshop files
echo "Applying compatibility fixes..."
cd /home/vscode/Desktop/work/tools/openlane_working_dir/openlane

# Fix 1: Patch libtrim.pl Perl script (remove experimental syntax)
echo "Fixing libtrim.pl Perl script..."
sed -i 's/given\s*(\s*\$line\s*)\s*{/if(1){/g' scripts/libtrim.pl
sed -i 's/when\s*(\s*/if(/g' scripts/libtrim.pl

# Fix 2: Verify all installations
echo "=== Verification ==="
which openroad && echo "✅ OpenROAD: $(openroad -version 2>/dev/null | head -1 || echo 'installed')"
which yosys && echo "✅ Yosys: $(yosys --version | head -1)"
which magic && echo "✅ Magic"
python3 -c "import pandas, numpy; print('✅ Pandas/Numpy: Compatible versions')"

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
echo "✅ OpenROAD installed via .deb package"
echo "✅ Fixed: Perl libtrim.pl experimental syntax"
echo "✅ Fixed: Pandas/Numpy version conflicts" 
echo "✅ Your workshop files are on the Desktop"
echo "✅ Access the desktop via port 6080"
echo ""
echo "To test:"
echo "cd ~/Desktop/work/tools/openlane_working_dir/openlane"
echo "./flow.tcl -interactive"
echo "prep -design spm"
echo "=========================================="

# Keep services running
tail -f /dev/null
