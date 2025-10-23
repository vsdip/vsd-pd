#!/bin/bash

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
