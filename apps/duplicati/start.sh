#!/usr/bin/env bash



    if [[ -z ${DUPLICATI__WEBSERVICE_PASSWORD} ]]; then
        DUPLICATI__WEBSERVICE_PASSWORD="changeme"
    fi

    if [[ -n ${SETTINGS_ENCRYPTION_KEY} ]]; then
        # Enable settings encryption
        true
    else
        DUPLICATI__DISABLE_DB_ENCRYPTION="true"
        echo "***      Missing encryption key, unable to encrypt your settings database     ***"
        echo "*** Please set a value for SETTINGS_ENCRYPTION_KEY and recreate the container ***"
    fi


exec duplicati-server $@

