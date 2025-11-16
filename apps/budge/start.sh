# ===== From ./processed/budge/root/etc/s6-overlay//s6-rc.d/init-budge-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -d /app/www/public/backend/node_modules-tmp ]]; then
    echo "New container detected. Setting up app folder and fixing permissions."
    mv /app/www/public/backend/node_modules-tmp /app/www/public/backend/node_modules
    mv /app/www/public/frontend/node_modules-tmp /app/www/public/frontend/node_modules
fi

mkdir -p /config/log/npm

cd /app/www/public/backend/build || exit 1

npx typeorm migration:run

touch /app/www/public/backend/budge.sqlite

# permissions
lsiown -R abc:abc \
    /app/www/public \
    /config

# ===== From ./processed/budge/root/etc/s6-overlay//s6-rc.d/svc-budge/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

shopt -s globstar

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 5000" \
    cd /app/www/public/backend/build s6-setuidgid abc /usr/bin/npm run start --logs-dir /config/log/npm

