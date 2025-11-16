# ===== From ./processed/thelounge/root/etc/s6-overlay//s6-rc.d/init-thelounge-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/thelounge/root/etc/s6-overlay//s6-rc.d/svc-thelounge/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 9000" \
    s6-setuidgid abc thelounge start

