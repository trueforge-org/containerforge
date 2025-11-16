# ===== From ./processed/piper/root/etc/s6-overlay//s6-rc.d/init-piper-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p /run/piper-temp

# permissions

    /run/piper-temp

# ===== From ./processed/piper/root/etc/s6-overlay//s6-rc.d/svc-piper/run =====
#!/command/with-contenv bash
# shellcheck shell=bash

unset UPDATE_MODELS

if [[ -z ${LOCAL_ONLY} ]]; then
    UPDATE_MODELS=true
fi

exec python3 -m wyoming_piper \
        --uri 'tcp://0.0.0.0:10200' \
        --length-scale "${PIPER_LENGTH:-1.0}" \
        --noise-scale "${PIPER_NOISE:-0.667}" \
        --noise-w "${PIPER_NOISEW:-0.333}" \
        --speaker "${PIPER_SPEAKER:-0}" \
        --voice "${PIPER_VOICE}" \
        --data-dir /config \
        --download-dir /config \
        ${UPDATE_MODELS:+--update-voices} \
        ${NO_STREAMING:+--no-streaming}

