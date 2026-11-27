#!/usr/bin/env bash

# CATALINA_HOME (/app/tomcat) is read-only, so Tomcat's conf and webapp are copied into CATALINA_BASE (/tmp/tomcat) on every start.
# NOT PORTED: the upstream docker-entrypoint.sh writes PreConfig.js, PostConfig.js, server.xml and a keystore from DRAWIO_* variables.
# Those variables are left out of settings.yaml until ported; see docker-entrypoint.sh at d2e740b.
mkdir -p /tmp/tomcat/conf /tmp/tomcat/logs /tmp/tomcat/temp /tmp/tomcat/work /tmp/tomcat/webapps
rm -rf /tmp/tomcat/conf /tmp/tomcat/webapps/ROOT
cp -r /app/tomcat/conf /tmp/tomcat/conf
cp -r /app/tomcat/webapps/ROOT /tmp/tomcat/webapps/ROOT

exec /app/tomcat/bin/catalina.sh run
