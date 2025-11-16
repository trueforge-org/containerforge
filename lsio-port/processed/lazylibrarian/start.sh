# ===== From ./processed/lazylibrarian/root/etc/s6-overlay//s6-rc.d/init-lazylibrarian-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make folders
mkdir -p \
    /config/log \
    /config/cache \
    /downloads \
    /books

# copy config
if [[ ! -e /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

# update version.txt
cp /defaults/version.txt /config/cache/version.txt

# permissions
lsiown -R abc:abc \
    /config

lsiown abc:abc \
    /downloads \
    /books

# ===== From ./processed/lazylibrarian/root/etc/s6-overlay//s6-rc.d/svc-lazylibrarian/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5299" \
        s6-setuidgid abc python3 /app/lazylibrarian/LazyLibrarian.py \
        --datadir /config --nolaunch

