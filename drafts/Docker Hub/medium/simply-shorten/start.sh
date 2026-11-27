#!/usr/bin/env bash

# UNVERIFIED: storage path /config/db comes from the chart; confirm against app config.
mkdir -p /config/db

cd /app
exec java -jar /app/application.jar
