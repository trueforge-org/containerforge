# ===== From ./processed/mylar3/root/etc/s6-overlay//s6-rc.d/init-mylar3-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make folders
mkdir -p /config/{mylar,scripts}

# copy scripts folder to config
if [[ ! -f /config/scripts/autoProcessComics.py ]]; then
    cp -pr /app/mylar3/post-processing/* /config/scripts/
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/mylar3/root/etc/s6-overlay//s6-rc.d/svc-mylar3/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck  -d -n 300 -w 1000 -c "nc -z localhost 8090" \
        s6-setuidgid abc python3 /app/mylar3/Mylar.py --nolaunch \
        --datadir /config/mylar

