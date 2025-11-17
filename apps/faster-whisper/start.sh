#!/usr/bin/env bash

exec python3 -m wyoming_faster_whisper \
        --uri 'tcp://0.0.0.0:10300' \
        --model "${WHISPER_MODEL:-tiny-int8}" \
        --beam-size "${WHISPER_BEAM:-1}" \
        --language "${WHISPER_LANG:-en}" \
        --data-dir /config \
        --download-dir /config \
        ${LOCAL_ONLY:+--local-files-only}

