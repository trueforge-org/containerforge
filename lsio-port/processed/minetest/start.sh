# ===== From ./processed/minetest/root/etc/s6-overlay//s6-rc.d/init-minetest-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make our folders
mkdir -p \
    /config/.minetest/games \
    /config/.minetest/mods \
    /config/.minetest/main-config

if [[ ! -f "/config/.minetest/main-config/minetest.conf" ]]; then
    cp /defaults/minetest.conf /config/.minetest/main-config/minetest.conf
fi

if [[ ! -d "/config/.minetest/games/minimal" ]]; then
    cp -pr /defaults/games/* /config/.minetest/games/
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/minetest/root/etc/s6-overlay//s6-rc.d/svc-minetest/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -zu localhost 30000" \
        s6-setuidgid abc minetestserver --port 30000 \
        --config /config/.minetest/main-config/minetest.conf ${CLI_ARGS}

