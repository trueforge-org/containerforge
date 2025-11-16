# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/init-kasmvnc-config/run =====
#!/usr/bin/with-contenv bash

# default file copies first run
if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
  chown -R abc:abc /config/.config/openbox
fi
if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox && \
  cp /defaults/menu.xml /config/.config/openbox/menu.xml && \
  chown -R abc:abc /config/.config
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
  chown abc:abc ${HOME}/.XDG
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
  chown abc:abc \
    ${HOME}/.bashrc \
    ${HOME}/.local/ \
    ${HOME}/.local/bin \
    ${HOME}/.local/bin/{ncat,proot-apps,proot,jq,pversion}
elif ! diff -q /proot-apps/pversion ${HOME}/.local/bin/pversion > /dev/null; then
  cp /proot-apps/* ${HOME}/.local/bin/
  chown abc:abc ${HOME}/.local/bin/{ncat,proot-apps,proot,jq,pversion}
fi

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/init-nginx/run =====
#!/usr/bin/with-contenv bash

# nginx Path
NGINX_CONFIG=/etc/nginx/http.d/default.conf

# user passed env vars
CPORT="${CUSTOM_PORT:-3000}"
CHPORT="${CUSTOM_HTTPS_PORT:-3001}"
CUSER="${CUSTOM_USER:-abc}"
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
  chown -R abc:abc /config/ssl
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

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/init-video/run =====
#!/usr/bin/with-contenv bash

FILES=$(find /dev/dri /dev/dvb -type c -print 2>/dev/null)

for i in $FILES
do
    VIDEO_GID=$(stat -c '%g' "${i}")
    VIDEO_UID=$(stat -c '%u' "${i}")
    # check if user matches device
    if id -u abc | grep -qw "${VIDEO_UID}"; then
        echo "**** permissions for ${i} are good ****"
    else
        # check if group matches and that device has group rw
        if id -G abc | grep -qw "${VIDEO_GID}" && [ $(stat -c '%A' "${i}" | cut -b 5,6) = "rw" ]; then
            echo "**** permissions for ${i} are good ****"
        # check if device needs to be added to video group
        elif ! id -G abc | grep -qw "${VIDEO_GID}"; then
            # check if video group needs to be created
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [ -z "${VIDEO_NAME}" ]; then
                VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-z0-9' | head -c4)"
                groupadd "${VIDEO_NAME}"
                groupmod -g "${VIDEO_GID}" "${VIDEO_NAME}"
                echo "**** creating video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            fi
            echo "**** adding ${i} to video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            usermod -a -G "${VIDEO_NAME}" abc
        fi
        # check if device has group rw
        if [ $(stat -c '%A' "${i}" | cut -b 5,6) != "rw" ]; then
            echo -e "**** The device ${i} does not have group read/write permissions, attempting to fix inside the container.If it doesn't work, you can run the following on your docker host: ****\nsudo chmod g+rw ${i}\n"
            chmod g+rw "${i}"
        fi
    fi
done

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-de/run =====
#!/usr/bin/with-contenv bash

cd $HOME
exec s6-setuidgid abc \
  /bin/bash /defaults/startwm.sh

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-docker/run =====
#!/usr/bin/with-contenv bash

# We need to wait for kclient to be full up as docker init breaks audio
sleep 5

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

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-kasmvnc/run =====
#!/usr/bin/with-contenv bash

# Pass gpu flags if mounted
if ls /dev/dri/renderD* 1> /dev/null 2>&1 && [ -z ${DISABLE_DRI+x} ] && ! which nvidia-smi; then
  HW3D="-hw3d"
fi
if [ -z ${DRINODE+x} ]; then
  DRINODE="/dev/dri/renderD128"
fi

exec s6-setuidgid abc \
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

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-kclient/run =====
#!/usr/bin/with-contenv bash

# Mic Setup
if [ ! -f '/dev/shm/mic.lock' ]; then
  until [ -f /defaults/pid ]; do
    sleep .5
  done
  s6-setuidgid abc with-contenv pactl \
    load-module module-pipe-source \
    source_name=virtmic \
    file=/defaults/mic.sock \
    source_properties=device.description=LSIOMic \
    format=s16le \
    rate=44100 \
    channels=1
  s6-setuidgid abc with-contenv pactl \
    set-default-source virtmic
  touch /dev/shm/mic.lock
fi

# NodeJS wrapper
cd /kclient
exec s6-setuidgid abc \
  node index.js

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-nginx/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

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

# ===== From ./processed/kasmvnc/root/etc/s6-overlay//s6-rc.d/svc-pulseaudio/run =====
#!/usr/bin/with-contenv bash

exec s6-setuidgid abc \
  /usr/bin/pulseaudio \
    --log-level=0 \
    --log-target=stderr \
    --exit-idle-time=-1 > /dev/null 2>&1

