#!/usr/bin/env bash

# writable data lives in /config (storage, hotdir and outputs are linked there at build time)
mkdir -p /config/storage /config/hotdir /config/outputs

# JWT secret: generated once and kept in /config so restarts keep the same secret
# UNVERIFIED: storing the secret in /config conflicts with the keep-secrets-out-of-files rule. Revisit before merge.
if [ -z "${JWT_SECRET:-}" ]; then
  if [ ! -s /config/.jwt_secret ]; then
    (umask 077 && head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/.jwt_secret)
  fi
  export JWT_SECRET="$(cat /config/.jwt_secret)"
fi

# apply database migrations on every start; a failure stops the container
# UNVERIFIED: the DATABASE_URL in the copied .env.example resolves to /app/server/storage (linked to /config/storage)
cd /app/server || exit 1
./node_modules/.bin/prisma migrate deploy --schema=./prisma/schema.prisma || exit 1

# the collector runs alongside the server
cd /app/collector || exit 1
node index.js &

# run the server in the foreground so it is the final process
cd /app/server || exit 1
exec node index.js
