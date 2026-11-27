#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Runtime files (runtime JS, nginx temp and pid) live in /tmp.
mkdir -p /config/db /config/media /tmp/runtime /tmp/nginx

# Generate a random secret when none is set. It is only exported, never written to disk or passed on the command line.
if [ -z "${PAPERMERGE__SECURITY__SECRET_KEY:-}" ]; then
  echo "WARNING: PAPERMERGE__SECURITY__SECRET_KEY is not set; using a random key, sessions reset on restart" >&2
  PAPERMERGE__SECURITY__SECRET_KEY="$(/app/venv/bin/python -c 'import secrets; print(secrets.token_hex(32))')"
  export PAPERMERGE__SECURITY__SECRET_KEY
fi

# Init steps are idempotent: migrations, permission sync and the admin user (skipped when it already exists).
cd /app/papermerge-core
/app/venv/bin/alembic upgrade head
/app/venv/bin/paper-cli perms sync
if [ -n "${PAPERMERGE__SEARCH__URL:-}" ]; then
  /app/venv/bin/paper-cli index-schema apply
fi
if [ -n "${PAPERMERGE__AUTH__PASSWORD:-}" ]; then
  # auth-cli exits non-zero when the user already exists; that is expected on restarts.
  (cd /app/auth_server_app && /app/auth-venv/bin/auth-cli users create --superuser) || \
    echo "auth-cli: admin user not created (it may already exist)" >&2
fi

# UNVERIFIED: runtime config format. The UI reads window.__PAPERMERGE_RUNTIME_CONFIG__ from this file.
cat > /tmp/runtime/papermerge-runtime-config.js <<JS
window.__PAPERMERGE_RUNTIME_CONFIG__ = {
  ocr__lang_codes: "${PAPERMERGE__OCR__LANG_CODES:-deu,eng,ron}",
  ocr__default_lang_code: "${PAPERMERGE__OCR__DEFAULT_LANG_CODE:-deu}",
  ocr__automatic: ${PAPERMERGE__OCR__AUTOMATIC:-false}
};
JS

# Start the core and auth-server apps on loopback, then nginx on 8080. Stop everything when one of them exits.
/app/venv/bin/fastapi run papermerge/app.py --workers 2 --host 127.0.0.1 --port 8000 &
CORE_PID=$!

(cd /app/auth_server_app && exec /app/auth-venv/bin/fastapi run auth_server/main.py --workers 1 --host 127.0.0.1 --port 4010) &
AUTH_PID=$!

nginx -c /app/nginx/nginx.conf -g 'daemon off;' &
NGINX_PID=$!

trap 'kill "${CORE_PID}" "${AUTH_PID}" "${NGINX_PID}" 2>/dev/null || true' TERM INT
status=0
wait -n || status=$?
kill "${CORE_PID}" "${AUTH_PID}" "${NGINX_PID}" 2>/dev/null || true
wait || true
exit "${status}"
