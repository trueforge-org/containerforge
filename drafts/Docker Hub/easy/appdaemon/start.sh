#!/usr/bin/env bash
set -euo pipefail

# Config holds the HA token, so keep new files private
umask 077

CONF=/config
CFG="${CONF}/appdaemon.yaml"

mkdir -p "${CONF}/apps" "${CONF}/dashboards"

# Seed only when missing, never overwrite user state
if [[ ! -f "${CFG}" && ! -f "${CONF}/appdaemon.toml" ]]; then
    echo "[appdaemon] Seeding ${CFG} from defaults"
    cp /defaults/appdaemon.yaml "${CFG}"
fi
if [[ ! -f "${CONF}/apps/apps.yaml" && ! -f "${CONF}/apps/apps.toml" ]]; then
    echo "[appdaemon] Seeding ${CONF}/apps/apps.yaml from defaults"
    cp /defaults/apps.yaml "${CONF}/apps/apps.yaml"
fi

# Apply env on every start. Values go through strenv()/env() so yq never parses them as a script.
# UNVERIFIED: the yq binary is present in the python base (/usr/local/bin/yq).
set_str() {
    local val="${!1:-}"
    [[ -z "${val}" ]] && return 0
    VAL="${val}" yq -i "$2 = strenv(VAL)" "${CFG}"
}

set_num() {
    local val="${!1:-}"
    [[ -z "${val}" ]] && return 0
    if [[ ! "${val}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "[appdaemon] ${1} must be a number, ignoring" >&2
        return 0
    fi
    VAL="${val}" yq -i "$2 = env(VAL)" "${CFG}"
}

set_bool() {
    local val="${!1:-}"
    [[ -z "${val}" ]] && return 0
    if [[ "${val}" != "true" && "${val}" != "false" ]]; then
        echo "[appdaemon] ${1} must be true or false, ignoring" >&2
        return 0
    fi
    VAL="${val}" yq -i "$2 = env(VAL)" "${CFG}"
}

if [[ -f "${CONF}/appdaemon.toml" ]]; then
    echo "[appdaemon] appdaemon.toml found, env mapping skipped (edit the TOML file instead)"
elif [[ -f "${CFG}" ]]; then
    set_str HA_URL .appdaemon.plugins.HASS.ha_url
    set_str TOKEN .appdaemon.plugins.HASS.token
    set_bool HA_CERT_VERIFY .appdaemon.plugins.HASS.cert_verify
    set_str DASH_URL .http.url
    set_str TIMEZONE .appdaemon.time_zone
    set_num LATITUDE .appdaemon.latitude
    set_num LONGITUDE .appdaemon.longitude
    set_num ELEVATION .appdaemon.elevation
fi

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

exec /app/venv/bin/appdaemon -c "${CONF}" "$@"
