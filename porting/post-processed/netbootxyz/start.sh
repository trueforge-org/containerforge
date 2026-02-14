#!/usr/bin/env bash


# create local logs dir
mkdir -p \
    /config/menus/remote \
    /config/menus/local

# download menus if not found
if [[ ! -f /config/menus/remote/menu.ipxe ]]; then
    if [[ -z ${MENU_VERSION+x} ]]; then \
        MENU_VERSION=$(curl -sL "https://api.github.com/repos/netbootxyz/netboot.xyz/releases/latest" | jq -r '.tag_name')
    fi
    echo "[netbootxyz-init] Downloading Netboot.xyz at ${MENU_VERSION}"
    # menu files
    curl -o \
        /config/endpoints.yml -sL \
        "https://raw.githubusercontent.com/netbootxyz/netboot.xyz/${MENU_VERSION}/endpoints.yml"
    curl -o \
        /tmp/menus.tar.gz -sL \
        "https://github.com/netbootxyz/netboot.xyz/releases/download/${MENU_VERSION}/menus.tar.gz"
    tar xf \
        /tmp/menus.tar.gz -C \
        /config/menus/remote
    # boot files
    curl -o \
        /config/menus/remote/netboot.xyz-undionly.kpxe -sL \
        "https://github.com/netbootxyz/netboot.xyz/releases/download/${MENU_VERSION}/netboot.xyz-undionly.kpxe"
    curl -o \
        /config/menus/remote/netboot.xyz.efi -sL \
        "https://github.com/netbootxyz/netboot.xyz/releases/download/${MENU_VERSION}/netboot.xyz.efi"
    curl -o \
        /config/menus/remote/netboot.xyz.kpxe -sL \
        "https://github.com/netbootxyz/netboot.xyz/releases/download/${MENU_VERSION}/netboot.xyz.kpxe"
    # layer and cleanup
    echo -n "${MENU_VERSION}" > /config/menuversion.txt
    cp -r /config/menus/remote/* /config/menus
    rm -f /tmp/menus.tar.gz
fi

# make our folders
mkdir -p \
    /assets \
    /config/{nginx/site-confs,log/nginx} \
    /run \
    /var/lib/nginx/tmp/client_body \
    /var/tmp/nginx

# copy config files
if [[ ! -f /config/nginx/nginx.conf ]]; then
    cp /defaults/nginx.conf /config/nginx/nginx.conf
fi

if [[ ! -f /config/nginx/site-confs/default ]]; then
    if [ -z ${NGINX_PORT+x} ]; then
        NGINX_PORT=80
    fi
    sed -i "s/REPLACE_PORT/$NGINX_PORT/g" /defaults/default
    cp /defaults/default /config/nginx/site-confs/default
fi


## TODO: Deal with multi-exec
exec /usr/sbin/nginx -c /config/nginx/nginx.conf

exec /usr/sbin/in.tftpd --foreground --listen --user apps --secure ${PORT_RANGE:+--port-range $PORT_RANGE} /config/menus

cd /app
exec /usr/bin/node app.js

