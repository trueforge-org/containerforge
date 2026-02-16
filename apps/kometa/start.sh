#!/usr/bin/env bash
cp --update=none /app/kometa/config/config.yml.template /config/config.yml

CA_BUNDLE_PATH="/etc/ca-certificates.crt"
export SSL_CERT_FILE="${CA_BUNDLE_PATH}"
export CURL_CA_BUNDLE="${CA_BUNDLE_PATH}"
export REQUESTS_CA_BUNDLE="${CA_BUNDLE_PATH}"

IFS="|" read -r -a CLI_OPTIONS <<< "$CLI_OPTIONS_STRING"

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
fi

if { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--run|-r)([\s]|$)'; } && { echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; }; then
    exec \
         python3 /app/kometa/kometa.py "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--run|-r)([\s]|$)'; then
    exec \
         python3 /app/kometa/kometa.py --config "${CONFIG_FILE}" "${CLI_OPTIONS[@]}"
elif echo "${CLI_OPTIONS[@]}" | grep -qPo '([\s]|^)(--config|-c)([\s])(.+\/[^\/]+)\.(yml|yaml)'; then
    exec \
         python3 /app/kometa/kometa.py --run "${CLI_OPTIONS[@]}"
else
    exec \
         python3 /app/kometa/kometa.py --run --config "${CONFIG_FILE}" "${CLI_OPTIONS[@]}"
fi
