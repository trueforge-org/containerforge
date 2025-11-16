# ===== From ./processed/wikijs/root/etc/s6-overlay//s6-rc.d/init-wikijs-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${DB_TYPE} ]]; then
    printf "sqlite" > /run/s6/container_environment/DB_TYPE
fi

if [[ ! -f "/config/config.yml" ]]; then
    cp /defaults/config.yml /config/config.yml
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # permissions
    lsiown -R abc:abc \
        /config

    if grep -qe ' /data ' /proc/mounts; then
        lsiown abc:abc \
            /data
    fi
fi

# ===== From ./processed/wikijs/root/etc/s6-overlay//s6-rc.d/svc-wikijs/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export CONFIG_FILE="/config/config.yml"

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
            cd /app/wiki s6-setuidgid abc /usr/bin/node server
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
            cd /app/wiki /usr/bin/node server
fi

