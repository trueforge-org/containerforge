# ===== From ./processed/sickchill/root/etc/s6-overlay//s6-rc.d/init-sickchill-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# create symlinks
sitepackages=$(python -c "import site; print(site.getsitepackages()[0])")

symlinks=(
    "${sitepackages}"/sickchill/gui/slick/cache
)
for i in "${symlinks[@]}"; do
    rm -rf "$i"
    ln -s /config/"$(basename "$i")" "$i"
done

# permissions
echo "Setting permissions"
lsiown -R abc:abc \
    /config

# ===== From ./processed/sickchill/root/etc/s6-overlay//s6-rc.d/svc-sickchill/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8081" \
    s6-setuidgid abc python3 /lsiopy/bin/SickChill --datadir /config

