#!/usr/bin/env bash

mkdir -p /config

# Komga creates its database and settings under KOMGA_CONFIGDIR (/config) on first start.
# Temp and thumbnail scratch go to /tmp. Nothing is written to /app.
exec \
    java \
        -Dspring.profiles.include=docker \
        -Djava.io.tmpdir=/tmp \
        --enable-native-access=ALL-UNNAMED \
        -jar /app/komga/komga.jar \
        --spring.config.additional-location=file:/config/ \
        "$@"
