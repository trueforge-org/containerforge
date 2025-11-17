#!/usr/bin/env bash




# make folders
mkdir -p \
	/config/oscam

# copy config
if [[ ! -e /config/oscam/oscam.conf ]]; then
	cp /defaults/oscam.conf /config/oscam/oscam.conf
fi

# permissions

	/config





exec \
    
         /usr/bin/oscam -c /config/oscam





exec \
    /usr/sbin/pcscd -f

