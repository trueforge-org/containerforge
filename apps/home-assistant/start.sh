#!/usr/bin/env bash
set -euo pipefail

unset UV_SYSTEM_PYTHON

CA_BUNDLE_PATH="/etc/ca-certificates.crt"
export SSL_CERT_FILE="${CA_BUNDLE_PATH}"
export CURL_CA_BUNDLE="${CA_BUNDLE_PATH}"
export REQUESTS_CA_BUNDLE="${CA_BUNDLE_PATH}"

ln -sf /proc/self/fd/1 /config/home-assistant.log

exec python3 -m homeassistant --config /config "$@"
