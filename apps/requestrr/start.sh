
cd "/app/bin" || exit 1
exec "/app/bin/Requestrr.WebApi" -c "/config" -p "${WEBUI_PORTS%%/*}"
