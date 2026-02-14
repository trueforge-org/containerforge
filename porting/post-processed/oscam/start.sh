#!/usr/bin/env bash


# make folders
mkdir -p \
	/config/oscam

# copy config
if [[ ! -e /config/oscam/oscam.conf ]]; then
	cp /defaults/oscam.conf /config/oscam/oscam.conf
fi


## TODO: deal with multi exec
exec /usr/bin/oscam -c /config/oscam

exec /usr/sbin/pcscd -f

