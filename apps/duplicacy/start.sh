if [[ ! -f "/config/machine-id" ]]; then
    tr -dc 'a-f0-9' < /dev/urandom | fold -w 32 | head -n 1 > "/config/machine-id"
fi

if [[ ! -f "/config/settings.json" ]]; then
    echo '{
        "listening_address"     : "0.0.0.0:3875",
        "log_directory"         : "/logs",
        "temporary_directory"   : "/cache"
    }' > "/config/settings.json"
fi

if [[ ! -f "/config/duplicacy.json" ]]; then
    echo '{}' > "/config/duplicacy.json"
fi

HOME="/app"
export DUPLICACY_HOME="/config"
exec "/app/duplicacy_web"
