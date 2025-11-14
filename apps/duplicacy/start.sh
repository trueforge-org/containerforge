echo "Applying permissions to /cache"
chmod "=rwx" "/cache"
find "/cache" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +

echo "Applying permissions to /logs"
chmod "=rwx" "/logs"
find "/logs" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +

if [[ ! -f "/config/machine-id" ]]; then
    tr -dc 'a-f0-9' < /dev/urandom | fold -w 32 | head -n 1 > "/config/machine-id"
    find "/config/machine-id" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +
fi

if [[ ! -f "/config/settings.json" ]]; then
    echo '{
        "listening_address"     : "0.0.0.0:3875",
        "log_directory"         : "/logs",
        "temporary_directory"   : "/cache"
    }' > "/config/settings.json"
    find "/config/settings.json" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +
fi

if [[ ! -f "/config/duplicacy.json" ]]; then
    echo '{}' > "/config/duplicacy.json"
    find "/config/duplicacy.json" -maxdepth 0 \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +
fi

HOME="/app"
exec "/app/duplicacy_web"
