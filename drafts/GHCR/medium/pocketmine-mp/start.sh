#!/usr/bin/env bash
set -eu

# Persistent world data and plugins live on /config. Only creates directories when missing.
mkdir -p /config/data /config/plugins

# Download plugins listed in POCKETMINE_PLUGINS (space-separated, optional name:version).
# Only missing plugins are fetched, so restarts do not re-download.
for entry in ${POCKETMINE_PLUGINS:-}; do
    PLUGIN_NAME="${entry%%:*}"
    PLUGIN_VERSION="${entry#*:}"
    if [ "${PLUGIN_VERSION}" = "${entry}" ]; then
        PLUGIN_VERSION="latest"
    fi
    if [ ! -f "/config/plugins/${PLUGIN_NAME}.phar" ]; then
        echo "Downloading plugin ${PLUGIN_NAME} ${PLUGIN_VERSION}"
        # A failed download is logged and skipped, not fatal. Upstream's message used an unset $VERSION; fixed here.
        wget -O "/config/plugins/${PLUGIN_NAME}.phar" \
            "https://poggit.pmmp.io/get/${PLUGIN_NAME}/${PLUGIN_VERSION}" \
            || rm -f "/config/plugins/${PLUGIN_NAME}.phar"
    fi
done

# Word-split POCKETMINE_ARGS on purpose, like upstream.
read -ra pm_args <<<"${POCKETMINE_ARGS:-}"

# Run from /config so relative writes by PHP land on the volume, never in /opt/pocketmine.
cd /config
exec php /opt/pocketmine/PocketMine-MP.phar \
    --no-wizard \
    --enable-ansi \
    --data=/config/data \
    --plugins=/config/plugins \
    "${pm_args[@]}"
