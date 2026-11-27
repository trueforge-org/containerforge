#!/usr/bin/env bash
set -uo pipefail

export HOME=/tmp/home
mkdir -p /config /tmp/home /tmp/next-cache

# Random alphanumeric string of length $2, from urandom.
rand() {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$1" || true
}

# Login password: generated once into a mode 600 file unless PASSWORD or DISABLE_PASSWORD is set.
if [ -z "${PASSWORD:-}" ] && [ -z "${DISABLE_PASSWORD:-}" ]; then
  if [ ! -s /config/.notea_password ]; then
    (umask 077; rand 24 > /config/.notea_password)
  fi
  PASSWORD=$(cat /config/.notea_password)
  export PASSWORD
  echo "Generated Notea password is stored in /config/.notea_password"
fi

# Storage: without STORE_END_POINT, run the bundled MinIO on the /config volume.
if [ -z "${STORE_END_POINT:-}" ]; then
  creds=/config/.minio_credentials
  if [ ! -s "$creds" ]; then
    (umask 077; printf 'MINIO_ROOT_USER=%s\nMINIO_ROOT_PASSWORD=%s\n' "$(rand 20)" "$(rand 40)" > "$creds")
  fi
  # Values are alphanumeric only, so sourcing the file is safe.
  set -a
  . "$creds"
  set +a

  bucket="${STORE_BUCKET:-notea}"
  mkdir -p "/config/minio/${bucket}"
  minio server /config/minio --address :9000 --console-address 127.0.0.1:9001 &
  MINIO_PID=$!
  # UNVERIFIED: /minio/health/live path for this MinIO release.
  for _ in $(seq 1 60); do
    curl -fs -o /dev/null http://127.0.0.1:9000/minio/health/live && break
    sleep 1
  done

  export STORE_ACCESS_KEY="$MINIO_ROOT_USER"
  export STORE_SECRET_KEY="$MINIO_ROOT_PASSWORD"
  export STORE_END_POINT=http://localhost:9000
  export STORE_FORCE_PATH_STYLE=true
  export STORE_BUCKET="$bucket"
fi

export COOKIE_SECURE="${COOKIE_SECURE:-false}"

cd /app/notea
node_modules/.bin/next start -H 0.0.0.0 -p 3000 &
APP_PID=$!

# Stop both processes on SIGTERM or SIGINT, then exit.
trap 'kill -TERM "$APP_PID" ${MINIO_PID:-} 2>/dev/null; wait; exit 0' TERM INT

# Exit as soon as either process dies, so the container restarts.
wait -n
status=$?
kill -TERM "$APP_PID" ${MINIO_PID:-} 2>/dev/null
wait
exit "$status"
