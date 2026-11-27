#!/usr/bin/env bash

mkdir -p /config/WatchYourLAN

cd /config || exit 1
exec /app/WatchYourLAN -d /config/WatchYourLAN
