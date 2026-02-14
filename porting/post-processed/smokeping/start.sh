#!/usr/bin/env bash


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

if [[ -f "/config/httpd.conf" ]]; then
    PORT=$(grep -e "^Listen" /config/httpd.conf | awk -F ' ' '{print $2}')
fi


## TODO: deal with multi-exec
exec /usr/sbin/apachectl -D FOREGROUND

if [[ -n "${MASTER_URL}" ]] && [[ -n "${SHARED_SECRET}" ]] && [[ -n "${CACHE_DIR}" ]]; then
    install -g apps -o apps -m 400 -D <(echo "${SHARED_SECRET}") /var/smokeping/secret.txt
    exec \
         /usr/sbin/smokeping --master-url="${MASTER_URL}" --cache-dir="${CACHE_DIR}" --shared-secret="/var/smokeping/secret.txt" --nodaemon
else
    exec \
         /usr/sbin/smokeping --config="/etc/smokeping/config" --nodaemon
fi

