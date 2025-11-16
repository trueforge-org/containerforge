# ===== From ./processed/pairdrop/root/etc/s6-overlay//s6-rc.d/init-pairdrop-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc \
        /config
fi

# ===== From ./processed/pairdrop/root/etc/s6-overlay//s6-rc.d/svc-pairdrop/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ${RATE_LIMIT,,} = "true" ]]; then
    OPT_RATE_LIMIT="--rate-limit"
fi

if [[ ${WS_FALLBACK,,} = "true" ]]; then
    OPT_WS_FALLBACK="--include-ws-fallback"
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    HOME=/config exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
        cd /app/pairdrop s6-setuidgid abc npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
else
    HOME=/config exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
        cd /app/pairdrop npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
fi

