# ===== From ./processed/ngircd/root/etc/s6-overlay//s6-rc.d/init-ngircd-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make our folders
mkdir -p \
    /var/run/ngircd

# copy config
if [[ ! -f /config/ngircd.conf ]]; then
    cp /defaults/ngircd.conf /config/ngircd.conf
fi

# permissions
lsiown -R abc:abc \
    /config \
    /var/run/ngircd

# ===== From ./processed/ngircd/root/etc/s6-overlay//s6-rc.d/svc-ngircd/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 6667" \
        s6-setuidgid abc /usr/sbin/ngircd -n -f /config/ngircd.conf

