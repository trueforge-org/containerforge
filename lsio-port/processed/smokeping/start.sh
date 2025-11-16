# ===== From ./processed/smokeping/root/etc/s6-overlay//s6-rc.d/init-smokeping-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# create folders
mkdir -p \
    /config/site-confs \
    /run/apache2 \
    /var/cache/smokeping \
    /data

# copy config files

PREV_DIR=$(pwd)

cd /defaults/smoke-conf || exit
shopt -s globstar nullglob
for i in *; do
    if [[ ! -e "/config/${i}" ]]; then
        cp -v "${i}" "/config/${i}"
    fi
done

# Fix stupid Alpine packaging decision
sed -i 's|exec /usr/bin/smokeping_cgi /etc/config|exec /usr/bin/smokeping_cgi /etc/smokeping/config|' /usr/share/webapps/smokeping/smokeping.cgi

cd "${PREV_DIR}" || exit

# make symlinks
if [[ ! -L /var/www/localhost/smokeping ]]; then
    ln -sf /usr/share/webapps/smokeping /var/www/localhost/smokeping
fi

if [[ ! -L /var/www/localhost/smokeping/cache ]]; then
    ln -sf	/var/cache/smokeping /var/www/localhost/smokeping/cache
fi

if [[ ! -e /config/site-confs/smokeping.conf ]]; then
    cp /defaults/smokeping.conf /config/site-confs/smokeping.conf
fi

if [[ ! -e /config/httpd.conf ]]; then
    cp /defaults/httpd.conf /config/httpd.conf
fi

if [[ ! -L /etc/apache2/httpd.conf ]]; then
    ln -sf /config/httpd.conf /etc/apache2/httpd.conf
fi

if [[ ! -e /config/smokeping_secrets ]]; then
    cp /defaults/smokeping_secrets /config/smokeping_secrets
fi

if [[ ! -L /etc/smokeping/smokeping_secrets ]]; then
    ln -sf /config/smokeping_secrets /etc/smokeping/smokeping_secrets
fi

if [[ -e /config/ssmtp.conf ]]; then
    cp /config/ssmtp.conf /etc/ssmtp/ssmtp.conf
fi

if [[ ! -f /usr/bin/tcpping ]]; then
    install -m755 -D /defaults/tcpping /usr/bin/
fi

# permissions
chmod 777 /var/cache/fontconfig/
chmod o-rwx /config/smokeping_secrets

lsiown -R abc:abc \
    /config \
    /data \
    /run/apache2 \
    /usr/share/webapps/smokeping \
    /var/cache/smokeping \
    /var/www/localhost/smokeping

# ===== From ./processed/smokeping/root/etc/s6-overlay//s6-rc.d/svc-apache/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -f "/config/httpd.conf" ]]; then
    PORT=$(grep -e "^Listen" /config/httpd.conf | awk -F ' ' '{print $2}')
fi

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PORT:-80}" \
        /usr/sbin/apachectl -D FOREGROUND

# ===== From ./processed/smokeping/root/etc/s6-overlay//s6-rc.d/svc-smokeping/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "${MASTER_URL}" ]] && [[ -n "${SHARED_SECRET}" ]] && [[ -n "${CACHE_DIR}" ]]; then
    install -g abc -o abc -m 400 -D <(echo "${SHARED_SECRET}") /var/smokeping/secret.txt
    exec \
        s6-setuidgid abc /usr/sbin/smokeping --master-url="${MASTER_URL}" --cache-dir="${CACHE_DIR}" --shared-secret="/var/smokeping/secret.txt" --nodaemon
else
    exec \
        s6-setuidgid abc /usr/sbin/smokeping --config="/etc/smokeping/config" --nodaemon
fi

