#!/usr/bin/env bash
# ARM start for ContainerForge. Writable state lives in /config and /tmp; /app and /defaults are read-only.

ARM_CONFIG=/config/arm

# create directory structure
mkdir -p \
    "${ARM_CONFIG}" \
    /config/media/raw \
    /config/media/transcode \
    /config/media/completed \
    /config/music \
    /config/logs \
    /config/db

# seed config files only when missing or empty (never overwrite user state)
if [[ ! -s "${ARM_CONFIG}/arm.yaml" ]]; then
    cp /defaults/arm.yaml "${ARM_CONFIG}/arm.yaml"
    # point the path keys at /config on first seed
    # UNVERIFIED: these key names are placeholders; read the real keys from the seeded arm.yaml before enabling.
    sed -i \
        -e 's|^\(RAW_PATH:\).*|\1 /config/media/raw|' \
        -e 's|^\(TRANSCODE_PATH:\).*|\1 /config/media/transcode|' \
        -e 's|^\(COMPLETED_PATH:\).*|\1 /config/media/completed|' \
        -e 's|^\(LOGPATH:\).*|\1 /config/logs|' \
        -e 's|^\(DBFILE:\).*|\1 /config/db/arm.db|' \
        "${ARM_CONFIG}/arm.yaml"
fi
for f in apprise.yaml abcde.conf; do
    if [[ ! -s "${ARM_CONFIG}/${f}" ]]; then
        cp "/defaults/${f}" "${ARM_CONFIG}/${f}"
    fi
done

# UNVERIFIED: how ARM is pointed at ${ARM_CONFIG} (the upstream default is /etc/arm/config, which is read-only here).
# Udev-driven disc detection does not run rootless, so the UI is the only entry point in this draft.
export HOME=/config
export TMPDIR=/tmp
cd /app/arm || exit 1

# UNVERIFIED: runui.py binds 0.0.0.0:8080; check the bind address on first run.
exec /app/venv-arm/bin/python /app/arm/arm/runui.py
