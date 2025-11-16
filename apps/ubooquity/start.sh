# ===== From ./processed/ubooquity/root/etc/s6-overlay//s6-rc.d/init-ubooquity-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make our folders
mkdir -p \
    /config/fonts

# copy config
if [[ ! -f /config/preferences.json ]]; then
    cp /defaults/preferences.json /config/preferences.json
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/ubooquity/root/etc/s6-overlay//s6-rc.d/svc-ubooquity/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

JAVAMEM=${MAXMEM:-512}
PORT=$(jq -r '.adminPortNumber' < /config/preferences.json)

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PORT:-2203}" \
        cd /app/ubooquity s6-setuidgid abc java -Xmx"$JAVAMEM"m \
        -jar /app/ubooquity/Ubooquity.jar \
        --headless --host 0.0.0.0 --remoteadmin \
        --workdir /config

