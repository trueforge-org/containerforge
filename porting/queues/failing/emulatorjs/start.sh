#!/usr/bin/env bash


# check if ipfs is disabled
if [ -z ${DISABLE_IPFS+x} ]; then

    # ipfs migrate check on startup
    if [[ -d "/data/.ipfs" ]]; then
        echo "[ipfs-upgrade] Checking if fs-repo needs to be upgraded (this may take some time)"
        HOME=/data  /usr/bin/fs-repo-migrations -y -to 15
    fi

    # ipfs config
    if [[ ! -d "/data/.ipfs" ]]; then
        HOME=/data ipfs init --profile lowpower
    fi
fi

# link user data to frontend
if [[ ! -L '/emulatorjs/frontend/user' ]]; then
    ln -s /data /emulatorjs/frontend/user
fi

# Default profile directory
if [[ ! -d '/config/profile/default' ]]; then
    mkdir -p /config/profile/default
    echo "input_menu_toggle_gamepad_combo = 3
system_directory = /home/web_user/retroarch/system/" >/config/profile/default/retroarch.cfg

fi
if [[ ! -f '/config/profile/profile.json' ]]; then
    echo '{}' >/config/profile/profile.json

fi

# nginx mime types
cp /defaults/mime.types /etc/nginx/mime.types

# allow users to mount in ro rom dirs
DIRS='3do atari2600 atari5200 atari7800 colecovision doom gba lynx n64 nes odyssey2 psx segaCD segaMD segaSaturn snes vb ws arcade atari5200 gb gbc jaguar msx nds ngp pce sega32x segaGG segaMS segaSG vectrex'
for DIR in ${DIRS}; do
    if [[ -d "/roms/${DIR}" ]] && [[ ! -L "/data/${DIR}/roms" ]]; then
        mkdir -p "/data/${DIR}"
        ln -s "/roms/${DIR}" "/data/${DIR}/roms"

    fi
done

cd /emulatorjs
## Config?
HOME=/data
exec node index.js

if [ ! -z ${DISABLE_IPFS+x} ]; then
  sleep infinity
fi

## Why?
exec ipfs daemon


if pgrep -f "[n]ginx:" > /dev/null; then
    pkill -ef [n]ginx:
fi

## TODO: Needs to be another container entirely
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf

cd /emulatorjs
HOME=/config
## TODO: What to do with this?
exec node profile.js

