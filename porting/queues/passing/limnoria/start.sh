#!/usr/bin/env bash


# create folders
mkdir -p \
    /config/{backup,conf,data,data/tmp,web,logs,plugins}

## TODO Move these to Dockerfile
PLUGIN_REQUIREMENTS=$(find /config/plugins -maxdepth 2 -name 'requirements.txt')
if [[ -n "${PLUGIN_REQUIREMENTS}" ]]; then
    apt-get add --no-cache --virtual=pip-dependencies \
        build-base \
        cargo \
        libffi-dev \
        openssl-dev \
        python3-dev
    while IFS= read -r line; do
        pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
            -r "${line}"
    done <<<"${PLUGIN_REQUIREMENTS}"
    apt-get del --purge \
        pip-dependencies
    rm -rf \
        /tmp/* \
        "${HOME}"/.cache \
        "${HOME}"/.cargo
fi

if [[ "$(find /config -maxdepth 1 -name '*.conf' | wc -l)" -gt 1 ]]; then
    echo "Multiple Limnoria configuration (*.conf) files found. Only one at a time may be used. Remove the extra configurations."
    while [[ ! "$(find /config -maxdepth 1 -name '*.conf' | wc -l)" -eq 1 ]]; do
        sleep 5
    done
fi

if [[ "$(find /config -maxdepth 1 -name '*.conf' | wc -l)" -lt 1 ]]; then
    echo "No config found. Please terminal into the container and run the wizard."
    echo "Example: \"docker exec -it -w /config -u apps limnoria limnoria-wizard\""
    while [[ ! -f "/config/configdone" ]]; do
        sleep 5
    done
fi

CONF_FILE=$(find /config -maxdepth 1 -name '*.conf')

exec limnoria \
        "${CONF_FILE}"

