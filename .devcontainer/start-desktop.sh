#!/usr/bin/env bash
set -euo pipefail

# ---- config ----
export DISPLAY=${DISPLAY:-:1}
SCREEN_GEOM=${SCREEN_GEOM:-1440x900x24}
NOVNC_WEBROOT=${NOVNC_WEBROOT:-/usr/share/novnc}
CERT_PATH="${HOME}/.novnc/self.pem"
VNC_PORT=5900
NOVNC_PORT=6080

log() { echo "[noVNC] $*"; }

# 0) ensure X/ICE unix sockets exist with correct ownership (tmp is ephemeral each start)
if [ ! -d /tmp/.X11-unix ] || [ ! -d /tmp/.ICE-unix ]; then
  if command -v sudo >/dev/null 2>&1; then
    sudo install -d -m 1777 -o root -g root /tmp/.X11-unix /tmp/.ICE-unix
  else
    # fallback: best effort without sudo
    mkdir -p /tmp/.X11-unix /tmp/.ICE-unix || true
    chmod 1777 /tmp/.X11-unix /tmp/.ICE-unix || true
  fi
fi

# 1) start Xvfb (virtual display)
if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
  log "starting Xvfb on $DISPLAY ($SCREEN_GEOM)"
  nohup Xvfb "$DISPLAY" -screen 0 "$SCREEN_GEOM" >/tmp/xvfb.log 2>&1 &
  # give X time to come up
  for _ in {1..20}; do xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break || sleep 0.2; done
fi

# 2) session dbus (quietly)
pgrep -x dbus-daemon >/dev/null 2>&1 || nohup dbus-daemon --session --fork >/tmp/dbus.log 2>&1 || true

# 3) XFCE session
pgrep -x xfce4-session >/dev/null 2>&1 || nohup startxfce4 >/tmp/xfce.log 2>&1 &

# 4) x11vnc exposing the display on :5900
if ! pgrep -x x11vnc >/dev/null 2>&1; then
  log "starting x11vnc on :$VNC_PORT"
  nohup x11vnc -display "$DISPLAY" -forever -shared -nopw -noxdamage -rfbport "$VNC_PORT" >/tmp/x11vnc.log 2>&1 &
fi

# 5) cert for TLS (Codespaces proxy expects HTTPS)
if [ ! -f "$CERT_PATH" ]; then
  log "creating self-signed cert at $CERT_PATH"
  mkdir -p "$(dirname "$CERT_PATH")"
  openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/CN=localhost" -keyout "$CERT_PATH" -out "$CERT_PATH" >/tmp/novnc-cert.log 2>&1
fi

# 6) websockify + noVNC webroot on 6080 (HTTPS)
if ! pgrep -f "websockify .* ${NOVNC_PORT} " >/dev/null 2>&1; then
  log "starting websockify on :$NOVNC_PORT (HTTPS)"
  nohup websockify --ssl-only --cert "$CERT_PATH" \
    --web "$NOVNC_WEBROOT" "$NOVNC_PORT" localhost:"$VNC_PORT" >/tmp/websockify.log 2>&1 &
fi

log "ready: open the forwarded port ${NOVNC_PORT} (public) and visit /vnc.html?autoconnect=1"
