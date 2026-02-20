#!/usr/bin/env bash


# make our folders
mkdir -p \
    /config/www/public/img

# create symlink to index.html
if [[ ! -L /app/www/public/index.html ]]; then
    ln -sf /config/www/public/index.html /app/www/public/index.html
fi

# update templates
cp /app/www/public/examples/example*.html /config/www/public/

# use custom js files if exist
if [[ -f /config/www/public/speedtest.js ]]; then
    cp /config/www/public/speedtest.js /app/www/public/speedtest.js
fi
if [[ -f /config/www/public/speedtest_worker.js ]]; then
    cp /config/www/public/speedtest_worker.js /app/www/public/speedtest_worker.js
fi

# sets apikey for ipinfo.io, if it exists
if [ -n "$IPINFO_APIKEY" ]; then
    sed -i "s/\$IPINFO_APIKEY = .*/\$IPINFO_APIKEY = '${IPINFO_APIKEY:-}';/g" \
    /app/www/public/backend/getIP_ipInfo_apikey.php
fi

# enables custom results page
if [ "$CUSTOM_RESULTS" == "true" ]; then
    echo "custom results"
    if [[ ! -e "/config/www/public/results/index.php" ]]; then
        mkdir -p /config/www/public/results/
        mv /app/www/public/results/index.php /config/www/public/results/index.php
    fi
    ln -sf /config/www/public/results/index.php /app/www/public/results/index.php
fi

# configure app settings
sed -i "\
    s|\$Sqlite_db_file.*|\$Sqlite_db_file = \'/config/speedtest_telemetry.sql\';|g; \
    s|\$enable_id_obfuscation.*|\$enable_id_obfuscation = true;|g;
    s|\$stats_password.*|\$stats_password = \'${PASSWORD}\';|g" \
    /app/www/public/results/telemetry_settings.php
if [ "$DB_TYPE" = "postgresql" ]; then
    sed -i "\
        s|\$db_type.*|\$db_type = \'${DB_TYPE}\';|g; \
        s|\$PostgreSql_username.*|\$PostgreSql_username = \'${DB_USERNAME}\';|g; \
        s|\$PostgreSql_password.*|\$PostgreSql_password = \'${DB_PASSWORD}\';|g; \
        s|\$PostgreSql_hostname.*|\$PostgreSql_hostname = \'${DB_HOSTNAME}\';|g; \
        s|\$PostgreSql_databasename.*|\$PostgreSql_databasename = \'${DB_NAME}\';|g" \
        /app/www/public/results/telemetry_settings.php
else
    sed -i \
        "s|\$db_type.*|\$db_type = \'sqlite\';|g" \
        /app/www/public/results/telemetry_settings.php
fi

exec php -S 0.0.0.0:80 -t /app/www/public
