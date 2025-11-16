# ===== From ./processed/ombi/root/etc/s6-overlay//s6-rc.d/init-ombi-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /run/ombi-temp

# ===== From ./processed/ombi/root/etc/s6-overlay//s6-rc.d/svc-ombi/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "${BASE_URL}" ]]; then
    EXTRA_PARAM="--baseurl ${BASE_URL}"
fi

exec \
            cd /app/ombi /app/ombi/Ombi --storage "/config" --host http://*:3579 ${EXTRA_PARAM}

