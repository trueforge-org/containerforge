# ===== From ./processed/oscam/root/etc/s6-overlay//s6-rc.d/init-oscam-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make folders
mkdir -p \
	/config/oscam

# copy config
if [[ ! -e /config/oscam/oscam.conf ]]; then
	cp /defaults/oscam.conf /config/oscam/oscam.conf
fi

# permissions
lsiown -R abc:abc \
	/config

# ===== From ./processed/oscam/root/etc/s6-overlay//s6-rc.d/svc-oscam/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8888" \
        s6-setuidgid abc /usr/bin/oscam -c /config/oscam

# ===== From ./processed/oscam/root/etc/s6-overlay//s6-rc.d/svc-pcsd/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    /usr/sbin/pcscd -f

