#!/usr/bin/env bash

# The Tomcat base lives in /tmp and is rebuilt on every start, so /app stays read-only
base=/tmp/catalina-base
rm -rf "${base}"
mkdir -p "${base}"/conf "${base}"/logs "${base}"/temp "${base}"/webapps "${base}"/work
cp -r /app/tomcat/conf/. "${base}/conf/"
cp /app/notarius/ROOT.war "${base}/webapps/ROOT.war"

export CATALINA_BASE="${base}"
exec /app/tomcat/bin/catalina.sh run
