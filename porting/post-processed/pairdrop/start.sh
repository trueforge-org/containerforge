#!/usr/bin/env bash


if [[ ${RATE_LIMIT,,} = "true" ]]; then
    OPT_RATE_LIMIT="--rate-limit"
fi

if [[ ${WS_FALLBACK,,} = "true" ]]; then
    OPT_WS_FALLBACK="--include-ws-fallback"
fi


HOME=/config

cd /app
exec npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
