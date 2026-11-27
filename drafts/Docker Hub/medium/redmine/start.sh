#!/usr/bin/env bash
set -eu

# Persistent files go to /config. Logs, pids and generated config go to /tmp (ephemeral).
mkdir -p /config/files /config/secrets /tmp/log /tmp/tmp/pids /tmp/tmp/pdf /tmp/redmine

# Secret key: from the environment, else generated once into /config/secrets and reused on later starts.
# Never logged. Whether Redmine reads SECRET_KEY_BASE this way is UNVERIFIED.
if [ -z "${SECRET_KEY_BASE:-}" ]; then
    if [ ! -s /config/secrets/secret_key_base ]; then
        umask 077
        ruby -rsecurerandom -e 'print SecureRandom.hex(64)' > /config/secrets/secret_key_base
    fi
    SECRET_KEY_BASE="$(cat /config/secrets/secret_key_base)"
fi
export SECRET_KEY_BASE

# database.yml is rewritten on every start. The password stays in the environment and is read by ERB, not written to the file.
# Env names here are UNVERIFIED against the upstream entrypoint (see settings.yaml).
cat > /tmp/redmine/database.yml <<'EOF'
production:
  adapter: postgresql
  host: <%= ENV["REDMINE_DB_POSTGRES"] %>
  database: <%= ENV["REDMINE_DB_DATABASE"] %>
  username: <%= ENV["REDMINE_DB_USERNAME"] %>
  password: <%= ENV["REDMINE_DB_PASSWORD"] %>
  encoding: utf8
EOF

cd /app/redmine

if [ "${RUN_DB_MIGRATE:-false}" = "true" ]; then
    bundle exec rake db:migrate
fi

exec bundle exec rails server -b 0.0.0.0 -p 3000 -e production
