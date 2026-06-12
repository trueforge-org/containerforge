#!/usr/bin/env bash

FULL_ARGS=( "$@" )

exec /usr/local/bin/ffmpeg "${FULL_ARGS[@]}"
