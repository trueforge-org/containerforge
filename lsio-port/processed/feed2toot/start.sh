# ===== From ./processed/feed2toot/root/etc/s6-overlay//s6-rc.d/init-feed2toot-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -f /config/feed2toot.ini ]]; then
    cp /defaults/feed2toot.ini /config/feed2toot.ini
fi

touch /config/hashtags.txt

# permissions
lsiown -R abc:abc \
    /config

