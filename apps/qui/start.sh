if [[ ! -f "/config/config.toml" ]]; then
    "/app/qui" generate-config --config-dir "/config"
    find "/config/config.toml" \( ! -user hotio -or ! -group hotio \) -exec chown hotio:hotio {} +
fi

export QUI__PORT="${WEBUI_PORTS%%/*}"
export QUI__HOST="0.0.0.0"
exec /app/qui" serve --config-dir "/config
