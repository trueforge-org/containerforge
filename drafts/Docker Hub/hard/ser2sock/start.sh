#!/usr/bin/env bash

set -euo pipefail

LISTENER_PORT="${LISTENER_PORT:-10000}"
BAUD_RATE="${BAUD_RATE:-9600}"
SERIAL_DEVICE="${SERIAL_DEVICE:-}"

if [[ -n "${SERIAL_DEVICE}" ]]; then
    if [[ ! -e "${SERIAL_DEVICE}" ]]; then
        echo "serial device ${SERIAL_DEVICE} not found, pass it with --device"
        exit 1
    fi
else
    echo "no SERIAL_DEVICE set, running in demo mode on a virtual port"
    # UNVERIFIED: ser2sock accepting a socat PTY and staying up without data.
    socat -d -d pty,raw,echo=0,link=/tmp/ttyV0 pty,raw,echo=0,link=/tmp/ttyV1 &
    for _ in $(seq 1 50); do
        [[ -e /tmp/ttyV0 ]] && break
        sleep 0.1
    done
    SERIAL_DEVICE=/tmp/ttyV0
fi

# ser2sock stays in the foreground unless -d is given. -i 0.0.0.0 binds all interfaces (the upstream default is also all).
exec ser2sock -p "${LISTENER_PORT}" -s "${SERIAL_DEVICE}" -b "${BAUD_RATE}" -i 0.0.0.0
