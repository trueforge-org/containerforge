#!/usr/bin/env bash


# default file copies first run
if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
  chown -R apps:apps /config/.config/openbox
fi
if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox && \
  cp /defaults/menu.xml /config/.config/openbox/menu.xml && \
  chown -R apps:apps /config/.config
fi
if [[ -f /usr/local/etc/kasmvnc/kasmvnc.yaml.lsio ]]; then
  mv \
    /usr/local/etc/kasmvnc/kasmvnc.yaml.lsio \
    /usr/local/etc/kasmvnc/kasmvnc.yaml
fi

# XDG Home
printf "${HOME}/.XDG" > /run/s6/container_environment/XDG_RUNTIME_DIR
if [ ! -d "${HOME}/.XDG" ]; then
  mkdir -p ${HOME}/.XDG
  chown apps:apps ${HOME}/.XDG
fi

# Locale Support
if [ ! -z ${LC_ALL+x} ]; then
  printf "${LC_ALL%.UTF-8}" > /run/s6/container_environment/LANGUAGE
  printf "${LC_ALL}" > /run/s6/container_environment/LANG
fi

# Remove window borders
if [[ ! -z ${NO_DECOR+x} ]] && [[ ! -f /decorlock ]]; then
  sed -i \
    's|</applications>|  <application class="*"> <decor>no</decor> </application>\n</applications>|' \
    /etc/xdg/openbox/rc.xml
  touch /decorlock
fi

# Fullscreen everything in openbox unless the user explicitly disables it
if [[ ! -z ${NO_FULL+x} ]] && [[ ! -f /fulllock ]]; then
  sed -i \
    '/<application class="\*"><maximized>yes<\/maximized><\/application>/d' \
    /etc/xdg/openbox/rc.xml
  touch /fulllock
fi

# Add proot-apps
if [ ! -f "${HOME}/.local/bin/proot-apps" ]; then
  mkdir -p ${HOME}/.local/bin/
  cp /proot-apps/* ${HOME}/.local/bin/
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
  chown apps:apps \
    ${HOME}/.bashrc \
    ${HOME}/.local/ \
    ${HOME}/.local/bin \
    ${HOME}/.local/bin/{ncat,proot-apps,proot,jq,pversion}
elif ! diff -q /proot-apps/pversion ${HOME}/.local/bin/pversion > /dev/null; then
  cp /proot-apps/* ${HOME}/.local/bin/
  chown apps:apps ${HOME}/.local/bin/{ncat,proot-apps,proot,jq,pversion}
fi

# nginx Path
NGINX_CONFIG=/etc/nginx/http.d/default.conf

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
  printf "${CUSER}:$(openssl passwd -apr1 ${PASSWORD})\n" > /etc/nginx/.htpasswd
  sed -i 's/#//g' ${NGINX_CONFIG}
fi

cd $HOME
exec /bin/bash /defaults/startwm.sh

# We need to wait for kclient to be full up as docker init breaks audio
sleep 5

## Do we even want this?
# Make sure this is a priv container
if [ -e /dev/cpu_dma_latency ]; then
  if [ "${START_DOCKER}" == "true" ]; then
    exec /usr/local/bin/dockerd-entrypoint.sh -l error
  else
    sleep infinity
  fi
fi

# if anything goes wrong with Docker don't loop
sleep infinity




# Pass gpu flags if mounted
if ls /dev/dri/renderD* 1> /dev/null 2>&1 && [ -z ${DISABLE_DRI+x} ] && ! which nvidia-smi; then
  HW3D="-hw3d"
fi
if [ -z ${DRINODE+x} ]; then
  DRINODE="/dev/dri/renderD128"
fi

exec  \
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
    -Log *:stdout:10




# Mic Setup
if [ ! -f '/dev/shm/mic.lock' ]; then
  until [ -f /defaults/pid ]; do
    sleep .5
  done
   with-contenv pactl \
    load-module module-pipe-source \
    source_name=virtmic \
    file=/defaults/mic.sock \
    source_properties=device.description=LSIOMic \
    format=s16le \
    rate=44100 \
    channels=1
   with-contenv pactl \
    set-default-source virtmic
  touch /dev/shm/mic.lock
fi

# NodeJS wrapper
cd /kclient
exec  \
  node index.js





if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes detected, sending SIGTERM"
    pkill -ef [n]ginx:
    sleep 1
fi

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes still active, sending SIGKILL"
    pkill -9 -ef [n]ginx:
    sleep 1
fi

exec /usr/sbin/nginx -g 'daemon off;'




exec  \
  /usr/bin/pulseaudio \
    --log-level=0 \
    --log-target=stderr \
    --exit-idle-time=-1 > /dev/null 2>&1

