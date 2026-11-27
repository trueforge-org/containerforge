#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"
: "${FIRESHARE_PORT:=8080}"
: "${ADMIN_USERNAME:=admin}"
: "${ADMIN_PASSWORD:=admin}"
export FIRESHARE_PORT ADMIN_USERNAME ADMIN_PASSWORD

# persistent state: sqlite db, secret key, processed media
mkdir -p /config/data /config/processed
rm -f /config/data/*.lock /config/data/jobs.sqlite

# library dirs are optional for an empty start, warn instead of failing on a read-only rootfs
for d in /videos /images; do
  mkdir -p "${d}" 2>/dev/null || echo "warning: ${d} is not writable, mount a volume there"
done

# ephemeral nginx and python scratch space
mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi \
  /tmp/nginx/uwsgi /tmp/nginx/scgi /tmp/nginx/cache /tmp/pip

# secret key: env wins, else reuse the stored key, else generate and store it (umask 077)
secret_file=/config/data/.secret_key
if [[ -z "${SECRET_KEY:-}" || "${SECRET_KEY}" == "PLACEHOLDERSECRETKEY000000000000" ]]; then
  if [[ ! -s "${secret_file}" ]]; then
    (umask 077 && /app/venv/bin/python -c 'import secrets; print(secrets.token_hex(32))' > "${secret_file}")
  fi
  SECRET_KEY="$(cat "${secret_file}")"
fi
export SECRET_KEY

# render the nginx template to /tmp
sed "s/__FIRESHARE_PORT__/${FIRESHARE_PORT}/" /defaults/nginx.conf.template > /tmp/nginx.conf
nginx -c /tmp/nginx.conf

cd /app/server
/app/venv/bin/flask db upgrade
# UNVERIFIED: command names taken from the upstream entrypoint summary
/app/venv/bin/fireshare migrate-game-assets || echo "migrate-game-assets failed, continuing"

if [[ ! -e /config/data/.boomerangs_generated ]]; then
  /app/venv/bin/python -m fireshare.cli create-boomerang-posters || echo "create-boomerang-posters failed, continuing"
  touch /config/data/.boomerangs_generated
fi

exec /app/venv/bin/gunicorn --config /app/server/gunicorn.conf.py \
  --bind=127.0.0.1:5000 "fireshare:create_app(init_schedule=True)"
