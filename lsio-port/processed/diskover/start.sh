# ===== From ./processed/diskover/root/etc/s6-overlay//s6-rc.d/init-diskover-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# setup web
mkdir -p \
    /config/diskover-web.conf.d

# touch db
if [[ ! -e "/config/diskoverdb.sqlite3" ]]; then
    touch /config/diskoverdb.sqlite3
fi

lsiown -R abc:abc /config

# ===== From ./processed/diskover/root/etc/s6-overlay//s6-rc.d/init-eol-check/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [ -f "/config/diskover.cfg" ]; then
    echo '
******************************************************
******************************************************
*                                                    *
*                                                    *
*     We have detected that you have an existing     *
*                                                    *
*   diskover v1 config file. Version 1 is now EOL.   *
*                                                    *
*    If you would like to upgrade, please create a   *
*                                                    *
*   new /config directory. If you want to continue   *
*                                                    *
*  using version 1, specify the tag v1.5.0.13-ls33.  *
*                                                    *
*                More information at                 *
*                                                    *
* https://github.com/diskoverdata/diskover-community *
*                                                    *
*                                                    *
******************************************************
******************************************************'
    while true; do
        sleep 3600
    done
fi

