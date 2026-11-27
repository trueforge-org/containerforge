#!/usr/bin/env bash
set -euo pipefail

CONFIG=/config/settings-user.cjs
RUN_CONFIG="${CONFIG}"

# Seed the user config once; never overwrite user state.
if [ ! -f "${CONFIG}" ]; then
  cp -p /app/quassel-web/settings.cjs "${CONFIG}"
fi

# Values from the environment end up in JavaScript, so accept only plain characters.
if [ -n "${QUASSEL_CORE:-}" ]; then
  if ! [[ "${QUASSEL_CORE}" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "QUASSEL_CORE contains unsupported characters" >&2; exit 1
  fi
  if ! [[ "${QUASSEL_PORT:-4242}" =~ ^[0-9]+$ ]]; then
    echo "QUASSEL_PORT must be numeric" >&2; exit 1
  fi
fi
if [ -n "${URL_BASE:-}" ]; then
  if ! [[ "${URL_BASE}" =~ ^/[A-Za-z0-9._/-]*$ ]] || [[ "${URL_BASE}" == *".."* ]]; then
    echo "URL_BASE contains unsupported characters" >&2; exit 1
  fi
fi

# Env injection writes a copy to /tmp, not /app (read-only at runtime).
if [ -n "${QUASSEL_CORE:-}" ]; then
  RUN_CONFIG=/tmp/quassel-web/settings-env.cjs
  mkdir -p /tmp/quassel-web
  cp -p /app/quassel-web/settings.cjs "${RUN_CONFIG}"
  # UNVERIFIED: these sed patterns follow the linuxserver init; check them against settings.cjs on the first run.
  sed -i \
    -e "s#host:.*//#host: '${QUASSEL_CORE}', //#g" \
    -e "s#port:.*,// quasselcore#port: ${QUASSEL_PORT:-4242}, // quasselcore#g" \
    "${RUN_CONFIG}"
  if [ -n "${URL_BASE:-}" ]; then
    sed -i "s#prefixpath:.*//#prefixpath: '${URL_BASE}', //#g" "${RUN_CONFIG}"
  fi
  if [ -z "${QUASSEL_HTTPS:-}" ]; then
    sed -i \
      -e "s#mode:.*// can be 'http'#mode: 'http', // can be 'http'#g" \
      -e "s#port:.*// Port on which to listen#port: 64080, // Port on which to listen#g" \
      "${RUN_CONFIG}"
  fi
fi

cd /app/quassel-web
export NODE_ENV=production

# Upstream settings.cjs defaults to https on 64443 (mode null). Without QUASSEL_HTTPS, force http on 64080
# so the port matches settings.yaml.
# UNVERIFIED: that the --mode/--port flags override the config file; confirm in app.js on the first run.
EXTRA_ARGS=()
if [ -z "${QUASSEL_HTTPS:-}" ]; then
  EXTRA_ARGS=(--mode http --port 64080)
fi

exec node app.js --config "${RUN_CONFIG}" "${EXTRA_ARGS[@]}"
