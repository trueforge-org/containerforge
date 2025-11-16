# ===== From ./processed/beets/root/etc/s6-overlay//s6-rc.d/init-beets-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# copy config
cp -n /defaults/beets.sh /config/beets.sh
cp -n /defaults/config.yaml /config/config.yaml

chmod +x /config/beets.sh

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # permissions
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/beets/root/etc/s6-overlay//s6-rc.d/svc-beets/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8337" \
            s6-setuidgid abc beet web
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8337" \
            beet web
fi

