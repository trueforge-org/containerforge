# ===== From ./processed/minisatip/root/etc/s6-overlay//s6-rc.d/svc-minisatip/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8875" \
        cd /app/satip ./minisatip ${RUN_OPTS} -f -x 8875

