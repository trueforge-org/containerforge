#!/usr/bin/env bash

mkdir -p /config/data /config/logs /config/plugins /config/client-plugins /config/config

# UNVERIFIED: shipped config file name and the variable that points the server at /config/config/config.json
# [ -s /config/config/config.json ] || cp /defaults/config.json /config/config/config.json

# UNVERIFIED: DB settings are applied from the environment on every start; the variable names are not confirmed yet
# export MM_SQLSETTINGS_DRIVERNAME=postgres
# export MM_SQLSETTINGS_DATASOURCE="<dsn built from confirmed inputs>"

cd /app/mattermost || exit 1
exec /app/mattermost/bin/mattermost
