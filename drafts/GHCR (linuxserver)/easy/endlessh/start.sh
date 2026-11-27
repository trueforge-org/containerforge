#!/usr/bin/env bash
# shellcheck shell=bash

# Extra endlessh flags, for example: CLI_ARGS="-m 10 -d 5000"
read -r -a cli_args <<< "${CLI_ARGS:-}"

exec endlessh -v -p 2222 "${cli_args[@]}"
