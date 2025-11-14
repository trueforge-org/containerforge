"

if [[ ! -f "/config/config.edn" ]]; then
    cp "/app/config.edn" "/config/config.edn"
    find "/config/config.edn" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +
fi

config="/config/config.edn" && export config

exec java -jar "/app/doplarr.jar"
