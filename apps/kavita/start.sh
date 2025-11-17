#!/usr/bin/env bash

cp -rn /defaults /config/
ln -s /app/appsettings.json /config/appsettings.json

exec /app/Kavita $@

