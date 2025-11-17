# ===== From ./processed/code-server/root/etc/s6-overlay//s6-rc.d/init-code-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/{extensions,data,workspace,.ssh}

if [[ ! -f /config/.bashrc ]]; then
    cp /root/.bashrc /config/.bashrc
fi

if [[ ! -f /config/.profile ]]; then
    cp /root/.profile /config/.profile
fi

# ===== From ./processed/code-server/root/etc/s6-overlay//s6-rc.d/svc-code-server/run =====
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

