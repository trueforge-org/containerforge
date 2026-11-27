#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export TMPDIR=/tmp

HOST="${HOST:-google.com}"
PING_INTERVAL="${PING_INTERVAL:-300}"
PING_TIMEOUT="${PING_TIMEOUT:-10}"
PING_RETRY="${PING_RETRY:-3600}"
PUSHOVER_APP_TOKEN="${PUSHOVER_APP_TOKEN:-}"
PUSHOVER_USER_TOKEN="${PUSHOVER_USER_TOKEN:-}"
PUSHOVER_TITLE="${PUSHOVER_TITLE:-Online Check}"
PUSHOVER_MESSAGE="${PUSHOVER_MESSAGE:-google.com is offline!}"
PUSHOVER_PRIORITY="${PUSHOVER_PRIORITY:-0}"

for value in "${PING_INTERVAL}" "${PING_TIMEOUT}" "${PING_RETRY}"; do
    if ! [[ "${value}" =~ ^[0-9]+$ ]]; then
        echo "Error: PING_INTERVAL, PING_TIMEOUT and PING_RETRY must be whole seconds." >&2
        exit 1
    fi
done

if [ -z "${PUSHOVER_APP_TOKEN}" ] || [ -z "${PUSHOVER_USER_TOKEN}" ]; then
    echo "Warning: PUSHOVER_APP_TOKEN or PUSHOVER_USER_TOKEN is empty; the container will check ${HOST} but cannot send alerts." >&2
fi

# Exit cleanly on SIGTERM. Sleep runs in the background so the trap fires at once.
trap 'exit 0' TERM INT

pause() {
    sleep "$1" &
    wait $!
}

send_alert() {
    if [ -z "${PUSHOVER_APP_TOKEN}" ] || [ -z "${PUSHOVER_USER_TOKEN}" ]; then
        return 0
    fi
    # --form-string sends each value as-is, so special characters in the message are safe.
    if ! curl -sS -f -o /dev/null \
        --form-string "token=${PUSHOVER_APP_TOKEN}" \
        --form-string "user=${PUSHOVER_USER_TOKEN}" \
        --form-string "title=${PUSHOVER_TITLE}" \
        --form-string "message=${PUSHOVER_MESSAGE}" \
        --form-string "priority=${PUSHOVER_PRIORITY}" \
        https://api.pushover.net/1/messages.json; then
        echo "Warning: Pushover request failed." >&2
    fi
}

while true; do
    if ping -c 1 -W "${PING_TIMEOUT}" "${HOST}" >/dev/null 2>&1; then
        echo "${HOST} is reachable"
        pause "${PING_INTERVAL}"
    else
        echo "${HOST} is not reachable"
        send_alert
        pause "${PING_RETRY}"
    fi
done
