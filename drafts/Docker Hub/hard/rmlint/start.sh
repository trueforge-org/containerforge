#!/usr/bin/env bash
set -eu

mkdir -p /config
cd /config

if [[ -n "${RMLINT_ARGS:-}" ]]; then
  # Word splitting on RMLINT_ARGS is intended, for example: /data -o json:/config/rmlint.json
  # shellcheck disable=SC2086
  exec rmlint ${RMLINT_ARGS}
fi

rmlint --version
echo "rmlint ready: idle, use docker exec or set RMLINT_ARGS"
# Upstream defines no daemon mode. Keep the container up for docker exec and for the container test.
exec sleep infinity
