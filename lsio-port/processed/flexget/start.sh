# ===== From ./processed/flexget/root/etc/s6-overlay//s6-rc.d/init-flexget-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p \
    /config/.flexget \
    /run/flexget-temp

FG_CONFIG_FILE="${FG_CONFIG_FILE:-/config/.flexget/config.yml}"
case "${FG_CONFIG_FILE}" in
  *yml)
    FG_LOCK_FILE="${FG_CONFIG_FILE/config.yml/.config-lock}"
    ;;
  *yaml)
    FG_LOCK_FILE="${FG_CONFIG_FILE/config.yaml/.config-lock}"
    ;;
  default)
    echo "invalid config file extension"
    exit 1
    ;;
esac

# clean up config-lock from unclean shutdown
if [[ -f "${FG_LOCK_FILE}" ]]; then
    rm -rf "${FG_LOCK_FILE}"
fi

if [[ ! -f "${FG_CONFIG_FILE}" ]]; then
    cp /default/config.yml "${FG_CONFIG_FILE}"
fi

if [[ -n "${FG_WEBUI_PASSWORD}" ]]; then
    if ! flexget -c "${FG_CONFIG_FILE}" --logfile "${FG_LOG_FILE:-/config/.flexget/flexget.log}" --loglevel error web passwd "${FG_WEBUI_PASSWORD}" | tee /dev/stderr | grep -q 'Updated password'; then
        echo "Halting init, please address the above issues and recreate the container"
        sleep infinity
    fi
fi

# permissions
lsiown -R abc:abc \
    /config \
    /run/flexget-temp

if grep -qe ' /data ' /proc/mounts; then
    lsiown abc:abc \
        /data
fi

# ===== From ./processed/flexget/root/etc/s6-overlay//s6-rc.d/svc-flexget/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5050" \
        cd /config s6-setuidgid abc python3 /lsiopy/bin/flexget \
            --loglevel "${FG_LOG_LEVEL:-info}" --logfile "${FG_LOG_FILE:-/config/.flexget/flexget.log}" -c "${FG_CONFIG_FILE:-/config/.flexget/config.yml}" daemon start --autoreload-config

