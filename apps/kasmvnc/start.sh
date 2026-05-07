#!/usr/bin/env bash

# default file copies first run
if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
  chown -R apps:apps /config/.config/openbox
fi
if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/menu.xml /config/.config/openbox/menu.xml
  chown -R apps:apps /config/.config
fi

# XDG Home
export XDG_RUNTIME_DIR="${HOME}/.XDG"
if [ ! -d "${XDG_RUNTIME_DIR}" ]; then
  mkdir -p "${XDG_RUNTIME_DIR}"
  chown apps:apps "${XDG_RUNTIME_DIR}"
fi

# Create cache directory for openbox
if [ ! -d "/config/.cache/openbox" ]; then
  mkdir -p "/config/.cache/openbox"
  chown -R apps:apps "/config/.cache"
fi

# Locale Support
if [ ! -z ${LC_ALL+x} ]; then
  export LANGUAGE="${LC_ALL%.UTF-8}"
  export LANG="${LC_ALL}"
fi

# Remove window borders (write to /tmp since /etc is read-only with --read-only)
if [[ ! -z ${NO_DECOR+x} ]] && [[ ! -f /tmp/decorlock ]]; then
  if [ -w /etc/xdg/openbox/rc.xml ]; then
    sed -i \
      's|</applications>|  <application class="*"> <decor>no</decor> </application>\n</applications>|' \
      /etc/xdg/openbox/rc.xml
  fi
  touch /tmp/decorlock
fi

# Fullscreen everything in openbox unless the user explicitly disables it
if [[ ! -z ${NO_FULL+x} ]] && [[ ! -f /tmp/fulllock ]]; then
  if [ -w /etc/xdg/openbox/rc.xml ]; then
    sed -i \
      '/<application class="\*"><maximized>yes<\/maximized><\/application>/d' \
      /etc/xdg/openbox/rc.xml
  fi
  touch /tmp/fulllock
fi

# Add proot-apps if available
if [ -d /proot-apps ] && [ "$(ls -A /proot-apps 2>/dev/null)" ]; then
  if [ ! -f "${HOME}/.local/bin/proot-apps" ]; then
    mkdir -p ${HOME}/.local/bin/
    cp /proot-apps/* ${HOME}/.local/bin/ 2>/dev/null || true
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
    chown -R apps:apps ${HOME}/.local/ ${HOME}/.bashrc 2>/dev/null || true
  elif [ -f /proot-apps/pversion ] && [ -f ${HOME}/.local/bin/pversion ] && ! diff -q /proot-apps/pversion ${HOME}/.local/bin/pversion > /dev/null 2>&1; then
    cp /proot-apps/* ${HOME}/.local/bin/ 2>/dev/null || true
    chown -R apps:apps ${HOME}/.local/bin/ 2>/dev/null || true
  fi
fi

# nginx Path - use /tmp since we may not be able to write to /etc/nginx
NGINX_CONFIG=/tmp/nginx-default.conf

# user passed env vars
CPORT="${CUSTOM_PORT:-3000}"
CHPORT="${CUSTOM_HTTPS_PORT:-3001}"
CUSER="${CUSTOM_USER:-apps}"
SFOLDER="${SUBFOLDER:-/}"

# create self signed cert
if [ ! -f "/config/ssl/cert.pem" ]; then
  mkdir -p /config/ssl
  openssl req -new -x509 \
    -days 3650 -nodes \
    -out /config/ssl/cert.pem \
    -keyout /config/ssl/cert.key \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
  chmod 600 /config/ssl/cert.key
  chown -R apps:apps /config/ssl
fi

# modify nginx config
cp /defaults/default.conf ${NGINX_CONFIG}
sed -i "s/3000/$CPORT/g" ${NGINX_CONFIG}
sed -i "s/3001/$CHPORT/g" ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$SFOLDER|g" ${NGINX_CONFIG}
if [ ! -z ${DISABLE_IPV6+x} ]; then
  sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi
if [ ! -z ${PASSWORD+x} ]; then
  mkdir -p /tmp/nginx
  printf "${CUSER}:$(openssl passwd -apr1 ${PASSWORD})\n" > /tmp/nginx/.htpasswd
  sed -i 's/#//g' ${NGINX_CONFIG}
  sed -i "s|/etc/nginx/.htpasswd|/tmp/nginx/.htpasswd|g" ${NGINX_CONFIG}
fi

# Copy nginx config to the right place if writable
if [ -w /etc/nginx/conf.d/ ]; then
  cp ${NGINX_CONFIG} /etc/nginx/conf.d/default.conf
elif [ -d /etc/nginx/http.d/ ] && [ -w /etc/nginx/http.d/ ]; then
  cp ${NGINX_CONFIG} /etc/nginx/http.d/default.conf
fi

# Set DISPLAY for X server
export DISPLAY=:1

# Start PulseAudio in the background
/usr/bin/pulseaudio \
  --log-level=0 \
  --log-target=stderr \
  --exit-idle-time=-1 > /dev/null 2>&1 &

# Start Xvnc server in background
# Pass gpu flags if mounted
HW3D=""
if ls /dev/dri/renderD* 1> /dev/null 2>&1 && [ -z ${DISABLE_DRI+x} ] && ! which nvidia-smi > /dev/null 2>&1; then
  HW3D="-hw3d"
fi
DRINODE="${DRINODE:-/dev/dri/renderD128}"

/usr/local/bin/Xvnc $DISPLAY \
  ${HW3D} \
  -PublicIP 127.0.0.1 \
  -drinode ${DRINODE} \
  -disableBasicAuth \
  -SecurityTypes None \
  -AlwaysShared \
  -http-header Cross-Origin-Embedder-Policy=require-corp \
  -http-header Cross-Origin-Opener-Policy=same-origin \
  -geometry 1024x768 \
  -sslOnly 0 \
  -RectThreads 0 \
  -websocketPort 6901 \
  -interface 0.0.0.0 \
  -Log *:stdout:10 &

# Wait for X server to be ready
sleep 2

# Start window manager
cd $HOME
/bin/bash /defaults/startwm.sh &

# Wait for window manager to start
sleep 2

# Start nginx (kill any zombie processes first)
if pgrep -f "[n]ginx:" >/dev/null; then
  echo "Zombie nginx processes detected, cleaning up"
  pkill -ef '[n]ginx:' 2>/dev/null || true
  sleep 1
fi

# Start nginx in background
if [ -f /etc/nginx/conf.d/default.conf ] || [ -f /etc/nginx/http.d/default.conf ] || [ -f ${NGINX_CONFIG} ]; then
  /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf &
fi

# Start kclient Node.js wrapper in foreground (this becomes our main process)
cd /kclient
exec node index.js
