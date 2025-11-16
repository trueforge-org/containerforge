# ===== From ./processed/faster-whisper/root/etc/s6-overlay//s6-rc.d/init-whisper-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

mkdir -p "/run/whisper-temp"


# ===== From ./processed/faster-whisper/root/etc/s6-overlay//s6-rc.d/svc-whisper/run =====
#!/command/with-contenv bash
# shellcheck shell=bash

exec \
            python3 -m wyoming_faster_whisper \
        --uri 'tcp://0.0.0.0:10300' \
        --model "${WHISPER_MODEL}" \
        --beam-size "${WHISPER_BEAM:-1}" \
        --language "${WHISPER_LANG:-en}" \
        --data-dir /config \
        --download-dir /config \
        ${LOCAL_ONLY:+--local-files-only}

