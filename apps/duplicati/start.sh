#!/usr/bin/env bash

if [[ -f "/config/Duplicati-server.sqlite" ]]; then
    # Existing install
    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        # Disable settings encryption
        DUPLICATI__DISABLE_DB_ENCRYPTION="true"
        echo "***      Missing encryption key, unable to encrypt your settings database     ***"
        echo "*** Please set a value for SETTINGS_ENCRYPTION_KEY and recreate the container ***"
    fi
else
    # New install
    if [[ -z ${DUPLICATI__WEBSERVICE_PASSWORD} ]]; then
        DUPLICATI__WEBSERVICE_PASSWORD="changeme"
    fi
    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        # Halt init
        echo "***      Missing encryption key, unable to encrypt your settings database     ***"
        echo "*** Please set a value for SETTINGS_ENCRYPTION_KEY and recreate the container ***"
        sleep infinity
    fi
fi


exec /app/duplicati/duplicati-server $@

