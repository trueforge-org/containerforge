/app/qui generate-config --config-dir "/config"

export QUI__PORT="${WEBUI_PORTS%%/*}"
export QUI__HOST="0.0.0.0"
exec "/app/qui" serve --config-dir "/config"
