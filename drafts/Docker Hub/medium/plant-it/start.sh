#!/usr/bin/env bash

mkdir -p /config/uploads /config/certificates /tmp/nginx

# client web server, daemonised; pid and temp paths are under /tmp (read-only rootfs)
nginx -c /etc/nginx/nginx.conf

cd /app/plant-it || exit 1

# UNVERIFIED: upload and certificate paths and any env names the backend reads (not in upstream Dockerfile)
exec java -Djava.io.tmpdir=/tmp -jar /app/plant-it/backend/app.jar
