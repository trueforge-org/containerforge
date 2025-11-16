# ===== From ./processed/raneto/root/etc/s6-overlay//s6-rc.d/init-raneto-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

folders=(
    /app/raneto/node_modules/@raneto/theme-default/dist/public/images
    /app/raneto/content
    /app/raneto/config
    /app/raneto/sessions
)

for i in "${folders[@]}"; do
    if [[ -e "$i" && ! -L "$i" && -e /config/"$(basename "$i")" ]]; then
        rm -Rf "$i" && \
        ln -s /config/"$(basename "$i")" "$i"
    fi

    if [[ -e "$i" && ! -L "$i" ]]; then
        mv "$i" /config/"$(basename "$i")" && \
        ln -s /config/"$(basename "$i")" "$i"
    fi
done

# upgrade support
if [[ -f /config/config.default.js ]]; then
  mv /config/config.default.js /config/config/config.js
fi

# copy default config
if [[ ! -f /config/config/config.js ]]; then
    cp /defaults/config.js /config/config/config.js
fi

# permissions
lsiown -R abc:abc \
    /config 

# ===== From ./processed/raneto/root/etc/s6-overlay//s6-rc.d/svc-raneto/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

HOST=0.0.0.0 exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3000" \
        cd /app/raneto s6-setuidgid abc node server.js

