# ===== From ./processed/kometa/root/etc/s6-overlay//s6-rc.d/init-kometa-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

cp /app/kometa/config/config.yml.template /config

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/kometa/root/etc/s6-overlay//s6-rc.d/init-kometa-oneshot/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

IFS="|" read -r -a CLI_OPTIONS <<< "$CLI_OPTIONS_STRING"

export KOMETA_LINUXSERVER=True

cd / || exit 1

# halt startup if no config file is found
if [[ -n "${KOMETA_CONFIG}" ]]; then
    CONFIG_FILE="${KOMETA_CONFIG}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; then
    CONFIG_FILE=$(echo "${CLI_OPTIONS[@]}" | grep -Po '([\s]|^)(--config|-c)([\s])\K(.+\/[^\/]+)\.(yml|yaml)')
else
    CONFIG_FILE="/config/config.yml"
fi

if [[ -n "${CONFIG_FILE}" ]] && [[ ! -e "${CONFIG_FILE}" ]]; then
    echo "No config file found at ${CONFIG_FILE}, halting init."
    echo "[ls.io-init] done."
    s6-rc -bad change
fi

if { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--run|-r)([\s]|$)'; } && { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; }; then
    s6-setuidgid abc python3 /app/kometa/kometa.py "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--run|-r)([\s]|$)'; then
    s6-setuidgid abc python3 /app/kometa/kometa.py --config "${CONFIG_FILE}" "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; then
    s6-setuidgid abc python3 /app/kometa/kometa.py --run "${CLI_OPTIONS[@]}"
else
    s6-setuidgid abc python3 /app/kometa/kometa.py --run --config "${CONFIG_FILE}" "${CLI_OPTIONS[@]}"
fi

# ===== From ./processed/kometa/root/etc/s6-overlay//s6-rc.d/svc-kometa/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

IFS="|" read -r -a CLI_OPTIONS <<< "$CLI_OPTIONS_STRING"

export KOMETA_LINUXSERVER=True

cd / || exit 1

# halt startup if no config file is found
if [[ -n "${KOMETA_CONFIG}" ]]; then
    CONFIG_FILE="${KOMETA_CONFIG}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; then
    CONFIG_FILE=$(echo "${CLI_OPTIONS[@]}" | grep -Po '([\s]|^)(--config|-c)([\s])\K(.+\/[^\/]+)\.(yml|yaml)')
else
    CONFIG_FILE="/config/config.yml"
fi

if [[ -n "${CONFIG_FILE}" ]] && [[ ! -e "${CONFIG_FILE}" ]]; then
    echo "No config file found at ${CONFIG_FILE}, halting init."
    s6-rc -bad change
fi

if { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--time|-t)([\s])'; } && { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; }; then
    exec \
        s6-setuidgid abc python3 /app/kometa/kometa.py "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--time|-t)([\s])'; then
    exec \
        s6-setuidgid abc python3 /app/kometa/kometa.py --config "${CONFIG_FILE}" "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; then
    exec \
        s6-setuidgid abc python3 /app/kometa/kometa.py --time "${KOMETA_TIME:-03:00}" "${CLI_OPTIONS[@]}"
else
    exec \
        s6-setuidgid abc python3 /app/kometa/kometa.py --config "${CONFIG_FILE}" --time "${KOMETA_TIME:-03:00}" "${CLI_OPTIONS[@]}"
fi

