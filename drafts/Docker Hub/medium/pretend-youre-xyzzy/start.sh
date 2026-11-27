#!/bin/sh
set -eu

# Tomcat state lives on /config; the install in /app stays read-only
base=/config/tomcat

mkdir -p "${base}/conf" "${base}/logs" "${base}/temp" "${base}/webapps" "${base}/work"

# seed Tomcat config only when missing, never overwrite user state
if [ ! -f "${base}/conf/server.xml" ]; then
    cp -a /app/tomcat/conf/. "${base}/conf/"
fi

# the WAR comes from the image, so refresh it on every start
cp -f /app/war/ROOT.war "${base}/webapps/ROOT.war"

export CATALINA_HOME=/app/tomcat
export CATALINA_BASE="${base}"
# Tomcat temp is ephemeral, keep it off /config
export CATALINA_TMPDIR=/tmp

# run from /config so relative writes by the app stay on persistent storage
cd /config

# the default Tomcat connector binds all interfaces; verify on a running container
exec /app/tomcat/bin/catalina.sh run
