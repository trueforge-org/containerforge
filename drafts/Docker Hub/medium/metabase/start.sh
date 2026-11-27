#!/usr/bin/env bash

# plugins dir is symlinked from /plugins; create its target on /config
mkdir -p /config/plugins

export MB_DB_TYPE="${MB_DB_TYPE:-h2}"
export MB_DB_FILE="${MB_DB_FILE:-/config/metabase.db}"
export MB_JETTY_HOST="${MB_JETTY_HOST:-0.0.0.0}"
export MB_JETTY_PORT="${MB_JETTY_PORT:-3000}"
export JAVA_TIMEZONE="${JAVA_TIMEZONE:-UTC}"

# extra JVM options, same variable name as upstream run_metabase.sh
IFS=" " read -r -a RUN_ARRAY <<< "${JAVA_OPTS:-}"

# cwd is /config, which is writable (upstream writes target/log relative to cwd)
cd /config || exit 1
exec java \
  -XX:+IgnoreUnrecognizedVMOptions \
  -Dfile.encoding=UTF-8 \
  -Djava.io.tmpdir=/tmp \
  -Duser.timezone="${JAVA_TIMEZONE}" \
  -XX:+CrashOnOutOfMemoryError \
  --add-opens java.base/java.nio=ALL-UNNAMED \
  --enable-native-access=ALL-UNNAMED \
  "${RUN_ARRAY[@]}" \
  -jar /app/metabase.jar
