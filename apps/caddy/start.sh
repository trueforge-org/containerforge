cp -nr /app/configfiles/* /config/
exec "/app/caddy" run --config "/config/Caddyfile" --adapter caddyfile "$@"
