# ===== From ./processed/snapdrop/root/etc/s6-overlay//s6-rc.d/init-snapdrop-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/snapdrop/root/etc/s6-overlay//s6-rc.d/svc-snapdrop/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

cd /app/www/server || exit 1

exec \
    s6-setuidgid abc /usr/bin/node index.js

