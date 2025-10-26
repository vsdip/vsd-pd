#!/usr/bin/env bash
# NOTE: avoid set -e to keep container from failing on benign warnings
set -u
# set -o pipefail  # (optional) keep off for maximum tolerance

export DISPLAY="${DISPLAY:-:1}"
SCREEN_GEOM="${SCREEN_GEOM:-1440x900x24}"
NOVNC_WEBROOT="${NOVNC_WEBROOT:-/usr/share/novnc}"
CERT_PATH="${HOME}/.novnc/self.pem"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"

log(){ echo "[noVNC] $*"; }

# 0) X/ICE sockets (don’t fail if sudo unavailable)
if [ ! -d /tmp/.X11-unix ] || [ ! -d /tmp/.ICE-unix ]; then
  if command -v sudo >/dev/null 2>&1; then
    sudo install -d -m 1777 -o root -g root /tmp/.X11-unix /tmp/.ICE-unix || true
  else
    mkdir -p /tmp/.X11-unix /tmp/.ICE-unix || true
    chmod 1777 /tmp/.X11-unix /tmp/.ICE-unix || true
  fi
fi

# Helper: detect if X is up without requiring xdpyinfo
_display_ready() {
  # Check for the UNIX socket file (/tmp/.X11-unix/X<display_num>)
  d="${DISPLAY#:}"
  [ -S "/tmp/.X11-unix/X$d" ]
}

# 1) Start Xvfb if not already running
if ! _display_ready; then
  log "starting Xvfb on $DISPLAY ($SCREEN_GEOM)"
  nohup Xvfb "$DISPLAY" -screen 0 "$SCREEN_GEOM" >/tmp/xvfb.log 2>&1 &
  for _ in $(seq 1 40); do _display_ready && break || sleep 0.2; done
fi

# 2) Session DBus (best effort)
pgrep -x dbus-daemon >/dev/null 2>&1 || nohup dbus-daemon --session --fork >/tmp/dbus.log 2>&1 || true

# 3) XFCE session (best effort)
pgrep -x xfce4-session >/dev/null 2>&1 || nohup startxfce4 >/tmp/xfce.log 2>&1 &

# 4) x11vnc exporting :$VNC_PORT
if ! pgrep -x x11vnc >/dev/null 2>&1; then
  log "starting x11vnc on :$VNC_PORT"
  nohup x11vnc -display "$DISPLAY" -forever -shared -nopw -noxdamage -rfbport "$VNC_PORT" \
    >/tmp/x11vnc.log 2>&1 &
fi

# 5) Create a self-signed cert in HOME (no sudo)
if [ ! -f "$CERT_PATH" ]; then
  log "creating self-signed cert at $CERT_PATH"
  mkdir -p "$(dirname "$CERT_PATH")"
  openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/CN=localhost" -keyout "$CERT_PATH" -out "$CERT_PATH" \
    >/tmp/novnc-cert.log 2>&1 || true
fi

# 6) websockify over HTTPS on :$NOVNC_PORT
if ! pgrep -f "websockify .* ${NOVNC_PORT} " >/dev/null 2>&1; then
  log "starting websockify on :$NOVNC_PORT (HTTPS)"
  # --ssl-only so Codespaces TLS probes succeed
  nohup websockify --ssl-only --cert "$CERT_PATH" --web "$NOVNC_WEBROOT" \
    "$NOVNC_PORT" localhost:"$VNC_PORT" >/tmp/websockify.log 2>&1 &
fi

log "ready: open forwarded port ${NOVNC_PORT} and visit /vnc.html?autoconnect=1"
exit 0
