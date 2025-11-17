#!/usr/bin/env bash

cp -rn /defaults /config/
cp /app/appsettings.json /config/config/appsettings.json

exec /app/Kavita $@

