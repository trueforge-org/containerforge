# ===== From ./processed/pwndrop/root/etc/s6-overlay//s6-rc.d/init-pwndrop-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/data

if [[ ! -f "/config/data/pwndrop.db" ]]; then
    SECRET_PATH=${SECRET_PATH:-/pwndrop}
    echo "New install detected, starting pwndrop with secret path ${SECRET_PATH}"
    echo -e "\n[setup]\nsecret_path = \"${SECRET_PATH}\"" >> /defaults/pwndrop.ini
fi

# permissions
lsiown -R abc:abc \
    /config \
    /defaults

# ===== From ./processed/pwndrop/root/etc/s6-overlay//s6-rc.d/svc-pwndrop/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8080" \
        s6-setuidgid abc \
            /app/pwndrop/pwndrop \
                -debug \
                -no-autocert \
                -no-dns \
                -config /defaults/pwndrop.ini

