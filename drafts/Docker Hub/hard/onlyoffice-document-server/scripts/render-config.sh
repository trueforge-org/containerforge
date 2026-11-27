#!/bin/sh
# Idempotent: writes the database, Redis, JWT and WOPI settings into /config/ds/local.json on every start.
# Secrets are read by jq from the environment ($ENV), so they never appear in argv.
# UNVERIFIED: the key paths below must be checked against the vendor run-document-server.sh and default.json.
set -eu

CFG=/config/ds/local.json
TMP="${CFG}.tmp"

jq \
  --arg dbType "${DB_TYPE:-postgres}" \
  --arg dbHost "${DB_HOST:-postgresql}" \
  --argjson dbPort "${DB_PORT:-5432}" \
  --arg dbName "${DB_NAME:-onlyoffice}" \
  --arg dbUser "${DB_USER:-onlyoffice}" \
  --arg redisHost "${REDIS_SERVER_HOST:-valkey}" \
  --argjson redisPort "${REDIS_SERVER_PORT:-6379}" \
  --argjson jwtOn "$( [ "${JWT_ENABLED:-true}" = "true" ] && echo true || echo false )" \
  --argjson wopiOn "$( [ "${WOPI_ENABLED:-false}" = "true" ] && echo true || echo false )" \
  --argjson privateIp "$( [ "${ALLOW_PRIVATE_IP_ADDRESS:-false}" = "true" ] && echo true || echo false )" \
  '
  .services.CoAuthoring.sql.type = $dbType
  | .services.CoAuthoring.sql.dbHost = $dbHost
  | .services.CoAuthoring.sql.dbPort = $dbPort
  | .services.CoAuthoring.sql.dbName = $dbName
  | .services.CoAuthoring.sql.dbUser = $dbUser
  | .services.CoAuthoring.sql.dbPass = env.DB_PWD
  | .services.CoAuthoring.redis.host = $redisHost
  | .services.CoAuthoring.redis.port = $redisPort
  | .services.CoAuthoring.token.enable.browser = $jwtOn
  | .services.CoAuthoring.token.enable.request.inbox = $jwtOn
  | .services.CoAuthoring.token.enable.request.outbound = $jwtOn
  | .services.CoAuthoring.secret.inbox.string = env.JWT_SECRET
  | .services.CoAuthoring.secret.outbox.string = env.JWT_SECRET
  | .services.CoAuthoring.secret.session.string = env.JWT_SECRET
  | .services.CoAuthoring.secret.browser.string = env.JWT_SECRET
  | .wopi.enable = $wopiOn
  | ."request-filtering-agent".allowPrivateIPAddress = $privateIp
  ' "${CFG}" > "${TMP}"

mv "${TMP}" "${CFG}"
