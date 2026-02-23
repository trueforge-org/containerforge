#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/{extensions,data,workspace,.ssh}

if [[ ! -f /config/.bashrc ]]; then
    cp /defaults/.bashrc /config/.bashrc
fi

if [[ ! -f /config/.profile ]]; then
    cp /defaults/.profile /config/.profile
fi

#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "${PASSWORD}" ]] || [[ -n "${HASHED_PASSWORD}" ]]; then
    AUTH="password"
else
    AUTH="none"
    echo "starting with no password"
fi

if [[ -z ${PROXY_DOMAIN+x} ]]; then
    PROXY_DOMAIN_ARG=""
else
    PROXY_DOMAIN_ARG="--proxy-domain=${PROXY_DOMAIN}"
fi

if [[ -z ${PWA_APPNAME} ]]; then
    PWA_APPNAME="code-server"
fi

    exec /app/code-server/bin/code-server \
                    --bind-addr 0.0.0.0:8443 \
                    --user-data-dir /config/data \
                    --extensions-dir /config/extensions \
                    --disable-telemetry \
                    --auth "${AUTH}" \
                    --app-name "${PWA_APPNAME}" \
                    "${PROXY_DOMAIN_ARG}" \
                    "${DEFAULT_WORKSPACE:-/config/workspace}"

