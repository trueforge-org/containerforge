#!/usr/bin/env bash

if [[ -f "/config/Duplicati-server.sqlite" ]]; then
    # Existing install
    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        # Disable settings encryption
        export DUPLICATI__DISABLE_DB_ENCRYPTION="true"
        echo "*** Missing encryption key; starting with settings database encryption disabled ***"
        echo "*** Set SETTINGS_ENCRYPTION_KEY to enable settings database encryption         ***"
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
        export DUPLICATI__DISABLE_DB_ENCRYPTION="true"
        echo "*** Missing encryption key; starting with settings database encryption disabled ***"
        echo "*** Set SETTINGS_ENCRYPTION_KEY to enable settings database encryption         ***"
    fi
fi


exec duplicati-server "$@"
