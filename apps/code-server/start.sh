# ===== From ./processed/code-server/root/etc/s6-overlay//s6-rc.d/init-code-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /config/{extensions,data,workspace,.ssh}

if [[ -z ${LSIO_NON_ROOT_USER} ]] && [[ -z ${LSIO_READ_ONLY_FS} ]]; then
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
fi

if [[ ! -f /config/.bashrc ]]; then
    cp /root/.bashrc /config/.bashrc
fi

if [[ ! -f /config/.profile ]]; then
    cp /root/.profile /config/.profile
fi

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # fix permissions (ignore contents of workspace)
    PUID=${PUID:-911}
    if [[ ! "$(stat -c %u /config/.profile)" == "${PUID}" ]]; then
        echo "Change in ownership or new install detected, please be patient while we chown existing files"
        echo "This could take some time"
        find /config -path "/config/workspace" -prune -o -exec lsiown abc:abc {} +
        lsiown abc:abc /config/workspace
    fi
    chmod 700 /config/.ssh
    if [[ -n "$(ls -A /config/.ssh)" ]]; then
        find /config/.ssh/ -type d -exec chmod 700 '{}' \;
        find /config/.ssh/ -type f -exec chmod 600 '{}' \;
        find /config/.ssh/ -type f -iname '*.pub' -exec chmod 644 '{}' \;
    fi
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

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z 127.0.0.1 8443" \
            s6-setuidgid abc \
                /app/code-server/bin/code-server \
                    --bind-addr 0.0.0.0:8443 \
                    --user-data-dir /config/data \
                    --extensions-dir /config/extensions \
                    --disable-telemetry \
                    --auth "${AUTH}" \
                    --app-name "${PWA_APPNAME}" \
                    "${PROXY_DOMAIN_ARG}" \
                    "${DEFAULT_WORKSPACE:-/config/workspace}"
else
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z 127.0.0.1 8443" \
            /app/code-server/bin/code-server \
                --bind-addr "[::]:8443" \
                --user-data-dir /config/data \
                --extensions-dir /config/extensions \
                --disable-telemetry \
                --auth "${AUTH}" \
                --app-name "${PWA_APPNAME}" \
                "${PROXY_DOMAIN_ARG}" \
                "${DEFAULT_WORKSPACE:-/config/workspace}"
fi

