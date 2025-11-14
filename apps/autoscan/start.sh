AUTOSCAN_CONFIG="/config/config.yml"    && export AUTOSCAN_CONFIG
AUTOSCAN_DATABASE="/config/autoscan.db" && export AUTOSCAN_DATABASE
AUTOSCAN_LOG="/config/autoscan.log"     && export AUTOSCAN_LOG

exec /app/autoscan $@
