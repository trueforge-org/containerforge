#!/usr/bin/env bash

# Required: the jar reads these from the environment, so they never go on the command line.
: "${fleet_database_url:?fleet_database_url is required (jdbc:mariadb://host:3306/fleet)}"
: "${fleet_database_password:?fleet_database_password is required}"

mkdir -p /config

exec \
    java \
        -Dfleet.config.base=/config \
        -Djava.io.tmpdir=/tmp \
        -Dlog4j2.formatMsgNoLookups=true \
        -jar /app/fleet/fleet.jar
