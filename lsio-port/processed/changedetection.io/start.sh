# ===== From ./processed/changedetection.io/root/etc/s6-overlay//s6-rc.d/init-changedetection-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/changedetection.io/root/etc/s6-overlay//s6-rc.d/svc-changedetection/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5000" \
            cd /app/changedetection s6-setuidgid abc python3 /app/changedetection/changedetection.py -d /config
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5000" \
            cd /app/changedetection python3 /app/changedetection/changedetection.py -d /config
fi

