#!/usr/bin/env bash


mkdir -p /config/site-confs /config/ssmtp /data

exec python3 -m http.server 80 --directory /usr/share/smokeping/www
