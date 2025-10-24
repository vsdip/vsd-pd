#!/bin/bash

# Download workshop files
cd /home/vscode/Desktop
wget -q -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip && rm work.zip

# Set environment
echo "export PDK_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
echo "cd /home/vscode/Desktop/work" >> ~/.bashrc

# Start VNC (all fixes incorporated)
Xvfb :1 -screen 0 1440x900x24 &
export DISPLAY=:1
sleep 2
dbus-daemon --session --fork
startxfce4 &
x11vnc -display :1 -forever -shared -nopw -bg
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "Setup complete! Access via port 6080"
echo "Your workshop is ready at: /home/vscode/Desktop/work"

# Keep alive
tail -f /dev/null
