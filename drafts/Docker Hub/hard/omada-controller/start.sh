#!/usr/bin/env bash
set -euo pipefail

OMADA_HOME=/app/omada
PROPS=/config/properties/omada.properties

mkdir -p /config/data /config/logs /config/properties /tmp/omada-work

# First run: seed properties and the web UI files. Existing files are never overwritten.
if [ -z "$(ls -A /config/properties)" ]; then
  cp -a "${OMADA_HOME}/properties.defaults/." /config/properties/
fi
if [ ! -d /config/data/html ]; then
  tar -xzf "${OMADA_HOME}/data-html.tar.gz" -C /config/data
fi
mkdir -p /config/data/pdf /config/data/db /config/data/keystore

# Port overrides, applied only when the variable is set. Numbers only, the value goes into sed.
# UNVERIFIED: property key names, read the upstream entrypoint-unified.sh before relying on them.
set_port() {
  local key="$1" value="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]]; then
    echo "Invalid port for ${key}: ${value}" >&2
    exit 1
  fi
  if grep -q "^${key}=" "$PROPS"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$PROPS"
  fi
}
if [ -n "${MANAGE_HTTP_PORT:-}" ]; then set_port "manage.http.port" "${MANAGE_HTTP_PORT}"; fi
if [ -n "${MANAGE_HTTPS_PORT:-}" ]; then set_port "manage.https.port" "${MANAGE_HTTPS_PORT}"; fi
if [ -n "${PORTAL_HTTP_PORT:-}" ]; then set_port "portal.http.port" "${PORTAL_HTTP_PORT}"; fi
if [ -n "${PORTAL_HTTPS_PORT:-}" ]; then set_port "portal.https.port" "${PORTAL_HTTPS_PORT}"; fi

# Embedded MongoDB, loopback only. Omada's default URI is mongodb://127.0.0.1:27217/omada.
# TODO: MONGO_EXTERNAL and EAP_MONGOD_URI are not handled yet.
mongod --bind_ip 127.0.0.1 --port 27217 \
  --dbpath /config/data/db --logpath /config/logs/mongod.log --logappend &
for _ in $(seq 1 60); do
  if (echo > /dev/tcp/127.0.0.1/27217) 2>/dev/null; then
    break
  fi
  sleep 1
done

# TLS keystore import from /cert is not implemented in this draft.
# Heap values are megabytes. UNVERIFIED against the upstream format.
# No writes to /app: work and logs point at /tmp and /config through symlinks made at build time.
cd "${OMADA_HOME}/lib"
exec java -server \
  -Xms"${JAVA_MIN_HEAP_SIZE:-128}"m \
  -Xmx"${JAVA_MAX_HEAP_SIZE:-1024}"m \
  -XX:MaxHeapFreeRatio=60 \
  -XX:MinHeapFreeRatio=30 \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/config/logs/java_heapdump.hprof \
  -Djava.awt.headless=true \
  -cp "${OMADA_HOME}/lib/*:/config/properties" \
  com.tplink.smb.omada.starter.OmadaLinuxMain
