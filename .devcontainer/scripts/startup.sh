#!/bin/bash

# Create a desktop shortcut for the work folder (optional but helpful)
cat > /home/openlane/Desktop/Open-Work-Folder.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Open Work Folder
Comment=Open the workshop work directory
Exec=xfce4-terminal -e "cd /home/openlane/Desktop/work && bash"
Icon=folder
Terminal=false
StartupNotify=true
EOF

chmod +x /home/openlane/Desktop/Open-Work-Folder.desktop

# Start Xvfb on display :0
Xvfb :0 -screen 0 1440x900x24 &

# Wait for Xvfb to start
sleep 2

# Start XFCE desktop environment on display :0
export DISPLAY=:0
startxfce4 &

# Start the VNC server, pointing to our XFCE desktop
x11vnc -display :0 -forever -shared -nopw &

# Start noVNC, proxying the VNC server to the web
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# Keep the script running
wait
