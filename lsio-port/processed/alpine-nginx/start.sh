# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-folders/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# make folders
mkdir -p \
    /config/{keys,php,www} \
    /config/log/{nginx,php} \
    /config/nginx/site-confs \

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-keygen/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

SUBJECT="/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
if [[ -f /config/keys/cert.key && -f /config/keys/cert.crt ]]; then
    echo "using keys found in /config/keys"
else
    echo "generating self-signed keys in /config/keys, you can replace these with your own keys if required"
    rm -f \
        /config/keys/cert.key \
        /config/keys/cert.crt || true
    openssl req -new -x509 -days 3650 -nodes -out /config/keys/cert.crt -keyout /config/keys/cert.key -subj "$SUBJECT"
fi

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-nginx/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# precreate log files
for file in /config/log/nginx/access.log /config/log/nginx/error.log; do
    if [[ ! -f "${file}" ]]; then
        touch "${file}"
    fi
done

# copy default config files if they don't exist
if [[ ! -f /config/nginx/nginx.conf ]]; then
    cp /defaults/nginx/nginx.conf.sample /config/nginx/nginx.conf
fi
if [[ ! -f /config/nginx/ssl.conf ]]; then
    cp /defaults/nginx/ssl.conf.sample /config/nginx/ssl.conf
fi
if [[ ! -f /config/nginx/site-confs/default.conf ]]; then
    cp /defaults/nginx/site-confs/default.conf.sample /config/nginx/site-confs/default.conf
fi

# force nginx.conf to include site-confs/*.conf instead of site-confs/*
sed -i -E "s#^(\s*)include /config/nginx/site-confs/\*;#\1include /config/nginx/site-confs/\*.conf;#" /config/nginx/nginx.conf

# copy index.html if no index file exists
INDEX_EXISTS=false
for file in /config/www/index.*; do
    if [[ -e "${file}" ]]; then
        INDEX_EXISTS=true
        break
    fi
done
if [[ ${INDEX_EXISTS} == false ]] && grep -Eq '^\s*index[^#]*index\.html' /config/nginx/**/*.conf; then
    cp /defaults/www/index.html /config/www/index.html
fi

# copy pre-generated dhparams or generate if needed
if [[ ! -f /config/nginx/dhparams.pem ]]; then
    cp /defaults/nginx/dhparams.pem /config/nginx/dhparams.pem
fi
if ! grep -q 'PARAMETERS' "/config/nginx/dhparams.pem"; then
    curl -o /config/nginx/dhparams.pem -L "https://ssl-config.mozilla.org/ffdhe4096.txt"
fi

# Set resolver, ignore ipv6 addresses
touch /config/nginx/resolver.conf
if ! grep -q 'resolver' /config/nginx/resolver.conf; then
    RESOLVERRAW=$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf)
    for i in ${RESOLVERRAW}; do
        if [[ "$(awk -F ':' '{print NF-1}' <<<"${i}")" -le 2 ]]; then
            RESOLVER="${RESOLVER} ${i}"
        fi
    done
    if [[ -z "${RESOLVER}" ]]; then
        RESOLVER="127.0.0.11"
    fi
    echo "Setting resolver to ${RESOLVER}"
    RESOLVEROUTPUT="# This file is auto-generated only on first start, based on the container's /etc/resolv.conf file. Feel free to modify it as you wish.\n\nresolver ${RESOLVER} valid=30s;"
    echo -e "${RESOLVEROUTPUT}" >/config/nginx/resolver.conf
fi

# Set worker_processes
touch /config/nginx/worker_processes.conf
if ! grep -q 'worker_processes' /config/nginx/worker_processes.conf; then
    WORKER_PROCESSES=$(nproc)
    echo "Setting worker_processes to ${WORKER_PROCESSES}"
    echo -e "# This file is auto-generated only on first start, based on the cpu cores detected. Feel free to change it to any other number or to auto to let nginx handle it automatically.\n\nworker_processes ${WORKER_PROCESSES};" >/config/nginx/worker_processes.conf
fi

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-permissions/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -z ${LSIO_READ_ONLY_FS} ]] && [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    # permissions
    lsiown -R abc:abc \
        /var/lib/nginx

    chmod -R 644 /etc/logrotate.d
fi

if [[ -f "/config/log/logrotate.status" ]]; then
    chmod 600 /config/log/logrotate.status
fi

chmod -R g+w \
    /config/nginx

if [[ -z ${LSIO_NON_ROOT_USER} ]]; then
    lsiown -R abc:abc \
        /config/keys \
        /config/log \
        /config/nginx \
        /config/php

    lsiown abc:abc \
        /config/www
fi

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-php/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# precreate log files
if [[ ! -f /config/log/php/error.log ]]; then
    touch /config/log/php/error.log
fi

# create local php.ini if it doesn't exist, set local timezone
if [[ ! -f /config/php/php-local.ini ]]; then
    printf "; Edit this file to override php.ini directives\\n\\n" >/config/php/php-local.ini
    # set default timezone
    printf "date.timezone = %s\\n" "${TZ:-UTC}" >>/config/php/php-local.ini
fi

# create override for www.conf if it doesn't exist
if [[ ! -f /config/php/www2.conf ]]; then
    printf "; Edit this file to override www.conf and php-fpm.conf directives and restart the container\\n\\n; Pool name\\n[www]\\n\\n" >/config/php/www2.conf
fi

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-samples/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# remove old samples
find /config/nginx/ \
    -name "*.conf.sample" \
    -type f \
    -delete

# copy new samples
find /defaults/nginx/ \
    -maxdepth 1 \
    -name "*.conf.sample" \
    -type f \
    -exec cp "{}" /config/nginx/ \;

find /defaults/nginx/site-confs/ \
    -maxdepth 1 \
    -name "*.conf.sample" \
    -type f \
    -exec cp "{}" /config/nginx/site-confs/ \;

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/init-version-checks/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# detect nginx configs with dates not matching the provided sample files
active_confs=$(find /config/nginx/ -name "*.conf" -type f 2>/dev/null)

for i in ${active_confs}; do
    if [ -f "${i}.sample" ]; then
        if [ "$(sed -nE 's|^## Version ([0-9]{4}\/[0-9]{2}\/[0-9]{2}).*|\1|p' "${i}")" != "$(sed -nE 's|^## Version ([0-9]{4}\/[0-9]{2}\/[0-9]{2}).*|\1|p' "${i}.sample")" ]; then
            active_confs_changed="│ $(printf '%10s' "$(sed -nE 's|^## Version ([0-9]{4}\/[0-9]{2}\/[0-9]{2}).*|\1|p' "${i}" | tr / -)") │ $(printf '%10s' "$(sed -nE 's|^## Version ([0-9]{4}\/[0-9]{2}\/[0-9]{2}).*|\1|p' "${i}.sample" | tr / -)") │ $(printf '%-70s' "${i}") │\n${active_confs_changed}"
        fi
    fi
done

if [ -n "${active_confs_changed}" ]; then
    echo "**** The following active confs have different version dates than the samples that are shipped. ****"
    echo "**** This may be due to user customization or an update to the samples. ****"
    echo "**** You should compare the following files to the samples in the same folder and update them. ****"
    echo "**** Use the link at the top of the file to view the changelog. ****"
    echo "┌────────────┬────────────┬────────────────────────────────────────────────────────────────────────┐"
    echo "│  old date  │  new date  │ path                                                                   │"
    echo "├────────────┼────────────┼────────────────────────────────────────────────────────────────────────┤"
    echo -e "${active_confs_changed%%\\n}"
    echo "└────────────┴────────────┴────────────────────────────────────────────────────────────────────────┘"
fi

# detect site-confs with wrong extension
site_confs_wrong_ext=$(find /config/nginx/site-confs/ -type f -not -name "*.conf" -not -name "*.conf.sample" 2>/dev/null)

if [ -n "${site_confs_wrong_ext}" ]; then
    echo "**** The following site-confs have extensions other than .conf ****"
    echo "**** This may be due to user customization. ****"
    echo "**** You should review the files and rename them to use the .conf extension or remove them. ****"
    echo "**** nginx.conf will only include site-confs with the .conf extension. ****"
    echo -e "${site_confs_wrong_ext}"
fi

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/svc-nginx/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes detected, sending SIGTERM"
    pkill -ef [n]ginx:
    sleep 1
fi

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes still active, sending SIGKILL"
    pkill -9 -ef [n]ginx:
    sleep 1
fi

exec /usr/sbin/nginx -e stderr

# ===== From ./processed/alpine-nginx/root/etc/s6-overlay//s6-rc.d/svc-php-fpm/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

exec /usr/sbin/php-fpm84 -F

