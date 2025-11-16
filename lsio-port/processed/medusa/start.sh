# ===== From ./processed/medusa/root/etc/s6-overlay//s6-rc.d/init-medusa-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -L "/app/medusa/Session.cfg" ]]; then
    ln -s /config/Session.cfg /app/medusa/Session.cfg
fi

# permissions
lsiown -R abc:abc \
    /config

# ===== From ./processed/medusa/root/etc/s6-overlay//s6-rc.d/svc-medusa/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

export MEDUSA_COMMIT_BRANCH=master

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 8081" \
    s6-setuidgid abc python3 /app/medusa/start.py \
    --nolaunch --datadir /config

