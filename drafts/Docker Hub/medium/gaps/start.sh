#!/bin/sh

ENABLE_SSL="${ENABLE_SSL:-false}"
ENABLE_LOGIN="${ENABLE_LOGIN:-false}"
BASE_URL="${BASE_URL:-}"

# profile mapping copied from upstream start.sh (v0.10.4)
if [ "${ENABLE_SSL}" = "true" ] && [ "${ENABLE_LOGIN}" = "true" ]; then
  profile="ssl"
elif [ "${ENABLE_SSL}" = "true" ]; then
  profile="ssl-no-login"
elif [ "${ENABLE_LOGIN}" = "true" ]; then
  profile="no-ssl"
else
  profile="no-ssl-no-login"
fi

cd /config || exit 1

exec java \
  -Xms256m -Xmx2048m \
  -jar \
  -Dspring.profiles.active="${profile}" \
  -Dserver.servlet.context-path="${BASE_URL}" \
  /app/gaps/gaps.jar
