#!/usr/bin/env bash


mkdir -p /opt/kasm/certs

# Login to Dockerhub when a daemon is available
if [[ -n "${DOCKER_HUB_USERNAME}" ]] && [[ -S /var/run/docker.sock ]]; then
    docker login --username "${DOCKER_HUB_USERNAME}" --password "${DOCKER_HUB_PASSWORD}"
fi

# Generate self cert for wizard
if [[ ! -f "/opt/kasm/certs/kasm_wizard.crt" ]]; then
    openssl req -x509 -nodes -days 1825 -newkey rsa:2048 \
        -keyout /opt/kasm/certs/kasm_wizard.key \
        -out /opt/kasm/certs/kasm_wizard.crt \
        -subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=$(hostname)/emailAddress=none@none.none"
fi

# Don't do anything if wizard is disabled
if [[ -f "/opt/NO_WIZARD" ]]; then
    sleep infinity
fi

cd /wizard || exit 1
exec node index.js
