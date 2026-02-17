#!/usr/bin/env bash


# make our folders
mkdir -p \
    /var/run/ngircd

# copy config
if [[ ! -f /config/ngircd.conf ]]; then
    cp /defaults/ngircd.conf /config/ngircd.conf
fi

exec /usr/sbin/ngircd -n -f /config/ngircd.conf

