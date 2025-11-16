# ===== From ./processed/minisatip/root/etc/s6-overlay//s6-rc.d/svc-minisatip/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec \
            cd /app/satip/minisatip ${RUN_OPTS} -f -x 8875

