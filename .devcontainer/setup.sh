#!/bin/bash

# Download and extract work.zip to Desktop
cd /home/vscode/Desktop
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"
unzip -q work.zip
rm work.zip

# Set PDK_ROOT
echo "export PDK_ROOT=/home/vscode/Desktop/work/tools/openlane_working_dir/pdks" >> ~/.bashrc
echo "export OPENLANE_ROOT=/home/vscode/OpenLane" >> ~/.bashrc
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

# Start VNC server and desktop (this runs in background)
sudo bash -c 'cat > /etc/systemd/system/vnc.service << EOFF
[Unit]
Description=VNC Server
After=network.target

[Service]
Type=simple
User=vscode
Group=vscode
WorkingDirectory=/home/vscode
Environment=DISPLAY=:1
ExecStartPre=/usr/bin/Xvfb :1 -screen 0 1440x900x24
ExecStart=/usr/bin/x11vnc -display :1 -forever -shared -nopw
ExecStartPost=/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5900
Restart=always

[Install]
WantedBy=multi-user.target
EOFF'

# Start the VNC service
sudo systemctl daemon-reload
sudo systemctl enable vnc.service
sudo systemctl start vnc.service

echo "Setup complete! Your workshop environment is ready."
echo "Access the desktop via the noVNC URL on port 6080"
