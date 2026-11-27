#!/usr/bin/env bash

# UNVERIFIED: scheduler (the ich777 image uses cron), SteamPrefill subcommand and argument syntax are not confirmed.
# Draft behaviour: run one prefill pass with PREFILL_PARAMS_STEAM, using /tmp as the working directory.
mkdir -p /config/logs /config/prefill

cd /tmp || exit 1
read -r -a prefill_args <<< "${PREFILL_PARAMS_STEAM:---recent}"
exec /app/steamprefill/SteamPrefill "${prefill_args[@]}"
