# ===== From ./processed/mstream/root/etc/s6-overlay//s6-rc.d/init-mstream-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p \
    /config/{album-art,db,keys,logs,sync} \
    /music

# create keys
if [[ ! -e /config/keys/certificate.pem ]]; then
    openssl req -x509 -nodes -days 3650 \
    -newkey rsa:2048 -keyout /config/keys/private-key.pem  -out /config/keys/certificate.pem \
    -subj "/CN=mstream"
fi

# copy config.json if doesn't exist
if [[ ! -e /config/config.json ]]; then
    cp /defaults/config.json /config/config.json
fi

if grep -q '"webAppDirectory": "public"' /config/config.json; then
    mv /config/config.json /config/config.json.v4-bak
    echo '
*************************************
*************************************
****                             ****
****                             ****
****   v4 config.json detected   ****
****                             ****
****   renaming to               ****
****                             ****
****   config.json.v4-bak        ****
****                             ****
****   due to incompatibility    ****
****                             ****
****   with v5                   ****
****                             ****
*************************************
*************************************'
fi

# permissions
lsiown -R abc:abc \
    /config \
    /app/mstream/bin

# ===== From ./processed/mstream/root/etc/s6-overlay//s6-rc.d/svc-mstream/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

PORT=$(jq -r '.port' /config/config.json)

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PORT}" \
        cd /app/mstream s6-setuidgid abc mstream -j /config/config.json

