#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -gt 0 ]]; then
  exec "$@"
fi

mkdir -p /config

export EULA=true

runtime_dir="${RUNTIME_DIR:-/config}"
cd "${runtime_dir}"

server_jar="${SERVER_JAR:-server.jar}"
if [[ ! -f "${server_jar}" ]]; then
  echo "Missing ${server_jar} in ${runtime_dir}" >&2
  echo "Place a Minecraft server jar at ${runtime_dir}/${server_jar} to start." >&2
  tail -f /dev/null
fi

exec mc-server-runner run \
  --stop-duration "${STOP_DURATION:-1m}" \
  --java-command "${JAVA_CMD:-java}" \
  --jar-file "${server_jar}" \
  --nogui
