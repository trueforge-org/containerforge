#!/usr/bin/env bash

set -euo pipefail

export SPLUNK_HOME=/app/splunk

read -r -a start_args <<< "${SPLUNK_START_ARGS:-}"
accepted=false
for arg in "${start_args[@]}"; do
    [[ "${arg}" == "--accept-license" ]] && accepted=true
done

# Splunk needs the license acceptance and an admin password. Halt visibly instead of exiting, as apps/bookstack does.
if [[ "${accepted}" != "true" || -z "${SPLUNK_PASSWORD:-}" ]]; then
    echo "Splunk needs SPLUNK_START_ARGS=--accept-license and SPLUNK_PASSWORD to start."
    echo "The license is not accepted on your behalf. Set both variables and restart the container."
    sleep infinity
fi

mkdir -p /config/etc /config/var /tmp/splunk

# Seed /config/etc once from the pristine copy. Never overwrite existing state.
if [[ -z "$(ls -A /config/etc 2>/dev/null)" ]]; then
    cp -a /app/splunk/etc.dist/. /config/etc/
fi

install -d -m 0755 /config/etc/system/local

# Open the forwarder receiver once, without overwriting user changes.
if [[ ! -f /config/etc/system/local/inputs.conf ]]; then
    cp /defaults/inputs.conf /config/etc/system/local/inputs.conf
fi

# First start only, while no passwd file exists. printf keeps the password out of argv.
# UNVERIFIED: Splunk consumes user-seed.conf on first start. The plan wanted it removed afterwards, which exec prevents here.
if [[ ! -f /config/etc/passwd ]]; then
    (
        umask 077
        printf '[user_info]\nUSERNAME = admin\nPASSWORD = %s\n' "${SPLUNK_PASSWORD}" > /config/etc/system/local/user-seed.conf
    )
fi

# UNVERIFIED: --nodaemon for 10.x (check `splunk start --help`). Splunk 10 may also need the general-terms flag.
exec /app/splunk/bin/splunk start --nodaemon --answer-yes --no-prompt "${start_args[@]}"
