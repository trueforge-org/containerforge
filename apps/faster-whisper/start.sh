#!/usr/bin/env bash

CA_BUNDLE_PATH="/etc/ca-certificates.crt"
export SSL_CERT_FILE="${CA_BUNDLE_PATH}"
export CURL_CA_BUNDLE="${CA_BUNDLE_PATH}"
export REQUESTS_CA_BUNDLE="${CA_BUNDLE_PATH}"

exec python3 -m wyoming_faster_whisper \
        --uri 'tcp://0.0.0.0:10300' \
        --model "${WHISPER_MODEL:-tiny-int8}" \
        --beam-size "${WHISPER_BEAM:-1}" \
        --language "${WHISPER_LANG:-en}" \
        --data-dir /config \
        --download-dir /config \
        ${LOCAL_ONLY:+--local-files-only}
