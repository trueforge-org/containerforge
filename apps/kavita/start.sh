#!/usr/bin/env bash

cp -rn /defaults /config

cd /app
exec /app/Kavita $@

