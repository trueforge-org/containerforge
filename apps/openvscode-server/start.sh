# ===== From ./processed/openvscode-server/root/etc/s6-overlay//s6-rc.d/init-openvscode-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/{workspace,.ssh}

if [[ -n "${SUDO_PASSWORD}" ]] || [[ -n "${SUDO_PASSWORD_HASH}" ]]; then
    echo "setting up sudo access"
    if ! grep -q '568' /etc/sudoers; then
        echo "adding 568 to sudoers"
        echo "568 ALL=(ALL:ALL) ALL" >> /etc/sudoers
    fi
    if [[ -n "${SUDO_PASSWORD_HASH}" ]]; then
        echo "setting sudo password using sudo password hash"
        sed -i "s|^568:\!:|568:${SUDO_PASSWORD_HASH}:|" /etc/shadow
    else
        echo "setting sudo password using SUDO_PASSWORD env var"
        echo -e "${SUDO_PASSWORD}\n${SUDO_PASSWORD}" | passwd 568
    fi
fi

if [[ ! -f /config/.bashrc ]]; then \
    cp /root/.bashrc /config/.bashrc
fi

if [[ ! -f /config/.profile ]]; then
    cp /root/.profile /config/.profile
fi

chmod 700 /config/.ssh || true
if [[ -n "$(ls -A /config/.ssh)" ]]; then
    chmod 600 /config/.ssh/* || true
fi

# ===== From ./processed/openvscode-server/root/etc/s6-overlay//s6-rc.d/svc-openvscode-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "$CONNECTION_SECRET" ]]; then
    CODE_ARGS="${CODE_ARGS} --connection-secret ${CONNECTION_SECRET}"
    echo "Using connection secret from ${CONNECTION_SECRET}"
elif [[ -n "$CONNECTION_TOKEN" ]]; then
    CODE_ARGS="${CODE_ARGS} --connection-token ${CONNECTION_TOKEN}"
    echo "Using connection token ${CONNECTION_TOKEN}"
else
    CODE_ARGS="${CODE_ARGS} --without-connection-token"
    echo "**** No connection token is set ****"
fi

exec /app/openvscode-server/bin/openvscode-server \
                --host 0.0.0.0 \
                --port 3000 \
                --disable-telemetry \
                ${CODE_ARGS}

