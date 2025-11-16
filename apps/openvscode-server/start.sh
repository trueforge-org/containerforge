# ===== From ./processed/openvscode-server/root/etc/s6-overlay//s6-rc.d/init-openvscode-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/{workspace,.ssh}

if [[ -n "${SUDO_PASSWORD}" ]] || [[ -n "${SUDO_PASSWORD_HASH}" ]]; then
    echo "setting up sudo access"
    if ! grep -q 'abc' /etc/sudoers; then
        echo "adding abc to sudoers"
        echo "abc ALL=(ALL:ALL) ALL" >> /etc/sudoers
    fi
    if [[ -n "${SUDO_PASSWORD_HASH}" ]]; then
        echo "setting sudo password using sudo password hash"
        sed -i "s|^abc:\!:|abc:${SUDO_PASSWORD_HASH}:|" /etc/shadow
    else
        echo "setting sudo password using SUDO_PASSWORD env var"
        echo -e "${SUDO_PASSWORD}\n${SUDO_PASSWORD}" | passwd abc
    fi
fi

if [[ ! -f /config/.bashrc ]]; then \
    cp /root/.bashrc /config/.bashrc
fi

if [[ ! -f /config/.profile ]]; then
    cp /root/.profile /config/.profile
fi

# fix permissions (ignore contents of /config/workspace)
echo "setting permissions::config"
find /config -path /config/workspace -prune -o -exec chown abc:abc {} +
chown abc:abc /config/workspace
echo "setting permissions::app"
chown -R abc:abc /app/openvscode-server

chmod 700 /config/.ssh
if [[ -n "$(ls -A /config/.ssh)" ]]; then
    chmod 600 /config/.ssh/*
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

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z 127.0.0.1 3000" \
        cd /app/openvscode-server s6-setuidgid abc \
            /app/openvscode-server/bin/openvscode-server \
                --host 0.0.0.0 \
                --port 3000 \
                --disable-telemetry \
                ${CODE_ARGS}

