# ===== From ./processed/znc/root/etc/s6-overlay//s6-rc.d/init-znc-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make folders
mkdir -p \
    /config/configs

# generate license file
if [[ ! -f /config/znc.pem ]]; then
    /usr/local/bin/znc -d /config -p
fi

while [[ ! -f "/config/znc.pem" ]]; do
    echo "waiting for pem file to be generated"
    sleep 2s
done

# copy config
if [[ ! -f /config/configs/znc.conf ]]; then
    cp /defaults/znc.conf /config/configs/znc.conf
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/znc/root/etc/s6-overlay//s6-rc.d/svc-znc/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

PORT=$(grep "Port =" /config/configs/znc.conf | awk -F '=' '{print $2;exit}')

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PORT}" \
        s6-setuidgid abc /usr/local/bin/znc -d /config \
        --foreground

