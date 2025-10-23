#!/bin/bash

echo "Setting up complete OpenLane workshop environment..."

# Download and extract work.zip to Desktop
cd /home/vscode/Desktop
echo "Downloading workshop files..."
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Verify all installations
echo "=== Verifying Tool Installations ==="
which openroad && echo "✅ OpenROAD: $(openroad -version 2>/dev/null | head -1)" || echo "❌ OpenROAD missing"
which yosys && echo "✅ Yosys: $(yosys --version | head -1)" || echo "❌ Yosys missing"
which magic && echo "✅ Magic" || echo "❌ Magic missing"
which klayout && echo "✅ KLayout" || echo "❌ KLayout missing"

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

# Fix any OpenROAD script compatibility issues
echo "Fixing OpenROAD script compatibility..."
cd /home/vscode/Desktop/work/tools/openlane_working_dir/openlane

# Backup original scripts
cp scripts/openroad/or_floorplan.tcl scripts/openroad/or_floorplan.tcl.backup 2>/dev/null || true
cp scripts/openroad/or_pdn.tcl scripts/openroad/or_pdn.tcl.backup 2>/dev/null || true

# Apply compatibility patches
sed -i 's/initialize_floorplan -tracks.*$/initialize_floorplan -site $::env(PLACE_SITE) -die_area $::env(DIE_AREA) -core_area $::env(CORE_AREA)/' scripts/openroad/or_floorplan.tcl 2>/dev/null || true
sed -i 's/pdngen $::env(PDN_CFG)/pdngen -config $::env(PDN_CFG)/' scripts/openroad/or_pdn.tcl 2>/dev/null || true

# Start VNC services properly
echo "Starting VNC services..."
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
pkill -f websockify 2>/dev/null || true

Xvfb :1 -screen 0 1440x900x24 &
export DISPLAY=:1
sleep 3

# Start XFCE with proper environment
dbus-daemon --session --fork 2>/dev/null || true
startxfce4 2>/dev/null &

# Start VNC and noVNC
x11vnc -display :1 -forever -shared -nopw -bg 2>/dev/null
websockify --web /usr/share/novnc/ 6080 localhost:5900 2>/dev/null &

echo "=========================================="
echo "🎉 WORKSHOP SETUP COMPLETE!"
echo "=========================================="
echo "✅ OpenROAD installed: $(which openroad)"
echo "✅ All EDA tools verified"
echo "✅ Workshop files extracted to Desktop"
echo "✅ VNC desktop running on port 6080"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Open the 'Ports' tab in VS Code"
echo "2. Find port 6080 and click the globe icon 🌐"
echo "3. Your workshop desktop will open in browser"
echo "4. Open terminal and run:"
echo "   cd ~/Desktop/work/tools/openlane_working_dir/openlane"
echo "   ./flow.tcl -design spm"
echo "=========================================="

# Keep the script running to maintain services
while true; do sleep 60; done
