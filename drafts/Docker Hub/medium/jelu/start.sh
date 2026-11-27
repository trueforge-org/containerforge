#!/usr/bin/env bash

# UNVERIFIED: Spring Boot binds to 0.0.0.0 by default; confirm on run
mkdir -p /config/database /config/files/images /config/files/imports

exec \
    java \
        -Djava.io.tmpdir=/tmp \
        -jar /app/jelu.jar \
        --spring.config.additional-location=optional:file:/config/
