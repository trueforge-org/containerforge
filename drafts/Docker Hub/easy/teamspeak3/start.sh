#!/usr/bin/env bash
set -euo pipefail

umask 077
mkdir -p /config/logs
# The server writes its database, files, SSH host key and allow/block lists relative to the cwd.
cd /config

# Rebuilt on every start from env. /tmp is ephemeral scratch space.
# UNVERIFIED: the binary reads the license acceptance; the official entrypoint does not.
cat > /tmp/ts3server.ini <<EOF
licensepath=/config
query_protocols=${TS3SERVER_QUERY_PROTOCOLS:-raw}
query_timeout=${TS3SERVER_QUERY_TIMEOUT:-300}
query_ssh_rsa_host_key=/config/ssh_host_rsa_key
query_ip_allowlist=/config/query_ip_allowlist.txt
query_ip_blocklist=/config/query_ip_blocklist.txt
dbplugin=ts3db_sqlite3
dbpluginparameter=
dbsqlpath=/app/sql/
dbsqlcreatepath=create_sqlite
dbconnections=10
dbclientkeepdays=${TS3SERVER_DB_CLIENTKEEPDAYS:-30}
logpath=/config/logs
logquerycommands=${TS3SERVER_LOG_QUERY_COMMANDS:-0}
logappend=0
serverquerydocs_path=/app/serverquerydocs/
query_port=${TS3SERVER_QUERY_PORT:-10011}
filetransfer_port=${TS3SERVER_FILETRANSFER_PORT:-30033}
default_voice_port=${TS3SERVER_DEFAULT_VOICE_PORT:-9987}
query_ssh_port=10022
EOF

if [ "${TS3SERVER_LICENSE:-}" != "accept" ]; then
  echo "TS3SERVER_LICENSE is not 'accept': set it to accept the TeamSpeak license. The server will show the license and exit." >&2
fi

# exec: the server receives signals directly.
exec /app/ts3server inifile=/tmp/ts3server.ini
