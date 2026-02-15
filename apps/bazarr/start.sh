#!/usr/bin/env bash

CA_BUNDLE_PATH="/etc/ca-certificates.crt"
export SSL_CERT_FILE="${CA_BUNDLE_PATH}"
export CURL_CA_BUNDLE="${CA_BUNDLE_PATH}"
export REQUESTS_CA_BUNDLE="${CA_BUNDLE_PATH}"

exec \
    /usr/local/bin/python \
        /app/bin/bazarr.py \
            --no-update True \
            --config /config \
            --port ${BAZARR__PORT}
