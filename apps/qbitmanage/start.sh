#!/usr/bin/env bash
# shellcheck shell=bash

umask "${UMASK:-002}"

cd "/config" || exit 1

if [[ -z "${QBT_CONFIG}" ]] && [[ -z "${QBT_CONFIG_DIR}" ]]; then
    export QBT_CONFIG_DIR="/config"
fi

if [[ -z "${ARGS}" ]]; then
    echo "qbitmanage ready: no ARGS provided; idling"
    exec sleep 999999
fi

# shellcheck disable=SC2086
exec python3 "/app/qbit_manage.py" ${ARGS}
