#!/usr/bin/env bash

# Data lives in /config/data, which the image links to /app/qinglong/data.
mkdir -p /config/data

cd "${QL_DIR:-/app/qinglong}" || exit 1

# UNVERIFIED: the panel start command. Upstream starts the panel through pm2 (ecosystem.config.js) from docker-entrypoint.sh.
# Replace this line with the real start command after reading those files in the probe run.
# UNVERIFIED: the panel must listen on 0.0.0.0:5700 (ql_port or QlPort); check the probe log.
exec npm --prefix "${QL_DIR:-/app/qinglong}" run start
