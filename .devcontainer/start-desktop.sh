#!/usr/bin/env bash
set -euo pipefail

LOGDIR=/var/log/novnc
mkdir -p "$LOGDIR"
chmod 777 "$LOGDIR" || true

# Export DISPLAY for this shell and future shells
export DISPLAY=:1
if ! grep -q "export DISPLAY=:1" /etc/profile.d/00-display.sh 2>/dev/null; then
  echo 'export DISPLAY=:1' | sudo tee /etc/profile.d/00-display.sh >/dev/null || true
fi

# Helper: start-if-not-running
start() {
  local name="$1"; shift
  if pgrep -x "$name" >/dev/null 2>&1; then
    echo "$name already running"
  else
    echo "starting $name: $*"
    nohup "$@" >>"$LOGDIR/$name.log" 2>&1 &
    sleep 0.5
  }
}

# Xvfb (virtual X server)
if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
  start Xvfb Xvfb "$DISPLAY" -screen 0 1440x900x24
fi

# dbus (some DE apps want a session bus)
if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
  nohup dbus-daemon --session --fork >>"$LOGDIR/dbus-daemon.log" 2>&1 || true
fi

# Start xfce (desktop env) only once
if ! pgrep -x xfce4-session >/dev/null 2>&1; then
  # ensure XDG_RUNTIME_DIR for vscode user
  export XDG_RUNTIME_DIR="/tmp/xdg-$(id -u)"
  mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR" || true
  nohup startxfce4 >>"$LOGDIR/startxfce4.log" 2>&1 &
fi

# x11vnc exports the X display as VNC on :5900
if ! pgrep -x x11vnc >/dev/null 2>&1; then
  start x11vnc x11vnc -display "$DISPLAY" -forever -shared -nopw -rfbport 5900 -nopw
fi

# websockify serves noVNC web UI and proxies to VNC
# Ubuntu path is /usr/share/novnc (double-check in your image if needed)
if ! pgrep -x websockify >/dev/null 2>&1; then
  start websockify websockify --web /usr/share/novnc 6080 localhost:5900
fi

# Health info
echo "noVNC should be reachable on port 6080."
echo "Processes:"
ps -ef | egrep 'Xvfb|xfce4|x11vnc|websockify' | grep -v egrep || true
