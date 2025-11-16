# ===== From ./processed/ombi/root/etc/s6-overlay//s6-rc.d/init-ombi-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /run/ombi-temp

# permissions
lsiown -R abc:abc \
    /run/ombi-temp \
    /config

lsiown abc:abc /app/ombi/ClientApp/dist/index.html > /dev/null 2>&1

# ===== From ./processed/ombi/root/etc/s6-overlay//s6-rc.d/svc-ombi/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "${BASE_URL}" ]]; then
    EXTRA_PARAM="--baseurl ${BASE_URL}"
fi

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z 127.0.0.1 3579" \
        cd /app/ombi s6-setuidgid abc /app/ombi/Ombi --storage "/config" --host http://*:3579 ${EXTRA_PARAM}

