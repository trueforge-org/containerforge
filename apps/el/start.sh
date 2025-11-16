# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/init-adduser/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

PUID=${PUID:-911}
PGID=${PGID:-911}

if [[ -z ${LSIO_READ_ONLY_FS} ]] && [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    USERHOME=$(grep abc /etc/passwd | cut -d ":" -f6)
    usermod -d "/root" abc

    groupmod -o -g "${PGID}" abc
    usermod -o -u "${PUID}" abc

    usermod -d "${USERHOME}" abc
fi

cat /etc/s6-overlay/s6-rc.d/init-adduser/branding

if [[ -f /donate.txt ]]; then
    echo '
To support the app dev(s) visit:'
    cat /donate.txt
fi
echo '
To support LSIO projects visit:
https://www.linuxserver.io/donate/

───────────────────────────────────────
GID/UID
───────────────────────────────────────'
echo "
User UID:    $(id -u abc)
User GID:    $(id -g abc)
───────────────────────────────────────"
if [[ -f /build_version ]]; then
    cat /build_version
    echo '
───────────────────────────────────────
    '
fi

lsiown abc:abc /app
lsiown abc:abc /config
lsiown abc:abc /defaults

# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/init-crontab-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

for cron_user in abc root; do
    if [[ -f "/etc/crontabs/${cron_user}" ]]; then
        lsiown "${cron_user}":"${cron_user}" "/etc/crontabs/${cron_user}"
        crontab -u "${cron_user}" "/etc/crontabs/${cron_user}"
    fi

    if [[ -f "/defaults/crontabs/${cron_user}" ]]; then
        # make folders
        mkdir -p \
            /config/crontabs

        # if crontabs do not exist in config
        if [[ ! -f "/config/crontabs/${cron_user}" ]]; then
            # copy crontab from system
            if crontab -l -u "${cron_user}" >/dev/null 2>&1; then
                crontab -l -u "${cron_user}" >"/config/crontabs/${cron_user}"
            fi

            # if crontabs still do not exist in config (were not copied from system)
            # copy crontab from image defaults (using -n, do not overwrite an existing file)
            cp -n "/defaults/crontabs/${cron_user}" /config/crontabs/
        fi

        # set permissions and import user crontabs
        lsiown "${cron_user}":"${cron_user}" "/config/crontabs/${cron_user}"
        crontab -u "${cron_user}" "/config/crontabs/${cron_user}"
    fi
done

# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/init-custom-files/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Directories
SCRIPTS_DIR="/custom-cont-init.d"

# Make sure custom init directory exists and has files in it
if [[ -e "${SCRIPTS_DIR}" ]] && [[ -n "$(/bin/ls -A ${SCRIPTS_DIR} 2>/dev/null)" ]]; then
    echo "[custom-init] Files found, executing"
    for SCRIPT in "${SCRIPTS_DIR}"/*; do
        NAME="$(basename "${SCRIPT}")"
        if [[ -f "${SCRIPT}" ]]; then
            echo "[custom-init] ${NAME}: executing..."
            /bin/bash "${SCRIPT}"
            echo "[custom-init] ${NAME}: exited $?"
        elif [[ ! -f "${SCRIPT}" ]]; then
            echo "[custom-init] ${NAME}: is not a file"
        fi
    done
else
    echo "[custom-init] No custom files found, skipping..."
fi

# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/init-envfile/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if find /run/s6/container_environment/FILE__* -maxdepth 1 > /dev/null 2>&1; then
    for FILENAME in /run/s6/container_environment/FILE__*; do
            SECRETFILE=$(cat "${FILENAME}")
            if [[ -f ${SECRETFILE} ]]; then
                FILESTRIP=${FILENAME//FILE__/}
                if [[ $(tail -n1 "${SECRETFILE}" | wc -l) != 0 ]]; then
                    echo "[env-init] Your secret: ${FILENAME##*/}"
                    echo "           contains a trailing newline and may not work as expected"
                fi
                cat "${SECRETFILE}" >"${FILESTRIP}"
                echo "[env-init] ${FILESTRIP##*/} set from ${FILENAME##*/}"
            else
                echo "[env-init] cannot find secret in ${FILENAME##*/}"
            fi
    done
fi

# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/init-migrations/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

MIGRATIONS_DIR="/migrations"
MIGRATIONS_HISTORY="/config/.migrations"

echo "[migrations] started"

if [[ ! -d ${MIGRATIONS_DIR} ]]; then
    echo "[migrations] no migrations found"
    exit
fi

for MIGRATION in $(find ${MIGRATIONS_DIR}/* | sort -n); do
    NAME="$(basename "${MIGRATION}")"
    if [[ -f ${MIGRATIONS_HISTORY} ]] && grep -Fxq "${NAME}" ${MIGRATIONS_HISTORY}; then
        echo "[migrations] ${NAME}: skipped"
        continue
    fi
    echo "[migrations] ${NAME}: executing..."
    chmod +x "${MIGRATION}"
    EXIT_CODE=$(
        /bin/bash "${MIGRATION}"
        echo $?
    )
    if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo "[migrations] ${NAME}: failed with exit code ${EXIT_CODE}, contact support"
        exit "${EXIT_CODE}"
    fi
    echo "${NAME}" >>${MIGRATIONS_HISTORY}
    echo "[migrations] ${NAME}: succeeded"
done

echo "[migrations] done"

# ===== From ./processed/el/root/etc/s6-overlay//s6-rc.d/svc-cron/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if builtin command -v crontab >/dev/null 2>&1 && [[ -n "$(crontab -l -u abc 2>/dev/null || true)" || -n "$(crontab -l -u root 2>/dev/null || true)" ]]; then
    if builtin command -v busybox >/dev/null 2>&1 && [[ $(busybox || true) =~ [[:space:]](crond)([,]|$) ]]; then
        exec busybox crond -f -S -l 5
    elif [[ -f /usr/bin/apt ]] && [[ -f /usr/sbin/cron ]]; then
        exec /usr/sbin/cron -f -L 5
    else
        echo "**** cron not found ****"
        sleep infinity
    fi
else
    sleep infinity
fi

