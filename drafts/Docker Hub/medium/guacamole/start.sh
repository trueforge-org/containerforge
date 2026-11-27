#!/usr/bin/env bash

set -euo pipefail

export GUACAMOLE_HOME="${GUACAMOLE_HOME:-/config/guacamole}"
export CATALINA_BASE="${CATALINA_BASE:-/tmp/tomcat}"

# Seed guacamole.properties only when it is missing. Never overwrite user state.
mkdir -p "${GUACAMOLE_HOME}/lib" "${GUACAMOLE_HOME}/extensions"
if [[ ! -f "${GUACAMOLE_HOME}/guacamole.properties" ]]; then
  cp /defaults/guacamole.properties "${GUACAMOLE_HOME}/guacamole.properties"
fi

# Tomcat state is rebuilt on each start under /tmp. The war is served at / (ROOT.war).
# The upstream image serves it at /guacamole instead.
rm -rf "${CATALINA_BASE}"
mkdir -p "${CATALINA_BASE}/webapps"
# UNVERIFIED: /etc/tomcat9 is the Debian/Ubuntu conf path. Confirm it in the build.
cp -r /etc/tomcat9 "${CATALINA_BASE}/conf"
cp /app/guacamole/guacamole.war "${CATALINA_BASE}/webapps/ROOT.war"

exec "${CATALINA_HOME}/bin/catalina.sh" run
