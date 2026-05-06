#!/usr/bin/env bash
set -u

# ---- ipfs (optional) -------------------------------------------------------
if [[ -z ${DISABLE_IPFS+x} ]] && command -v ipfs >/dev/null 2>&1; then
    if [[ -d "/data/.ipfs" ]]; then
        echo "[ipfs-upgrade] Checking if fs-repo needs to be upgraded (this may take some time)"
        HOME=/data /usr/bin/fs-repo-migrations -y -to 15 || true
    fi
    if [[ ! -d "/data/.ipfs" ]]; then
        HOME=/data ipfs init --profile lowpower || true
    fi
fi

# ---- frontend user data link ----------------------------------------------
if [[ -w /emulatorjs/frontend ]] && [[ ! -L /emulatorjs/frontend/user ]]; then
    ln -s /data /emulatorjs/frontend/user
fi

# ---- /config seeding -------------------------------------------------------
if [[ ! -d /config/profile/default ]]; then
    mkdir -p /config/profile/default
    cat >/config/profile/default/retroarch.cfg <<EOF
input_menu_toggle_gamepad_combo = 3
system_directory = /home/web_user/retroarch/system/
EOF
fi
if [[ ! -f /config/profile/profile.json ]]; then
    echo '{}' >/config/profile/profile.json
fi

# ---- nginx writable dirs (read-only-rootfs friendly) -----------------------
mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi /tmp/nginx/scgi
if [[ -w /etc/nginx ]] && [[ -f /defaults/mime.types ]]; then
    cp /defaults/mime.types /etc/nginx/mime.types
fi

# ---- bind-mount roms into /data -------------------------------------------
DIRS='3do atari2600 atari5200 atari7800 colecovision doom gba lynx n64 nes odyssey2 psx segaCD segaMD segaSaturn snes vb ws arcade gb gbc jaguar msx nds ngp pce sega32x segaGG segaMS segaSG vectrex'
for DIR in ${DIRS}; do
    if [[ -d "/roms/${DIR}" ]] && [[ ! -L "/data/${DIR}/roms" ]]; then
        mkdir -p "/data/${DIR}"
        ln -s "/roms/${DIR}" "/data/${DIR}/roms"
    fi
done

# ---- supervisor ------------------------------------------------------------
PIDS=()
shutdown() {
    trap - TERM INT
    for pid in "${PIDS[@]}"; do
        kill -TERM "$pid" 2>/dev/null || true
    done
    wait
    exit 0
}
trap shutdown TERM INT

# nginx (foreground via daemon off in nginx.conf)
/usr/sbin/nginx -c /etc/nginx/nginx.conf &
PIDS+=($!)

# profile service
( cd /emulatorjs && HOME=/config exec node profile.js ) &
PIDS+=($!)

# optional ipfs daemon
if [[ -z ${DISABLE_IPFS+x} ]] && command -v ipfs >/dev/null 2>&1; then
    HOME=/data ipfs daemon &
    PIDS+=($!)
fi

# main frontend service
( cd /emulatorjs && HOME=/data exec node index.js ) &
PIDS+=($!)

# exit when any child exits, then propagate shutdown to remaining children
wait -n
shutdown
