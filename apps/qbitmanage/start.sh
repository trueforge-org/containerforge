#!/command/with-contenv bash
# shellcheck shell=bash

umask "${UMASK}"

cd "/config" || exit 1

if [[ -z "${QBT_CONFIG}" ]] && [[ -z "${QBT_CONFIG_DIR}" ]]; then
    export QBT_CONFIG_DIR="/config"
fi

# shellcheck disable=SC2086
exec python3 "/app/qbit_manage.py" ${ARGS}
