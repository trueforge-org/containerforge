#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/pycache /tmp/dotnet

# Defaults match settings.yaml. A value set in the environment always wins.
export Zilean__Database__ConnectionString="${Zilean__Database__ConnectionString:-Host=postgresql;Database=zilean;Username=zilean;Password=MYPOSTGRESPASSWORD;Include Error Detail=true;Timeout=30;CommandTimeout=3600;}"
export Zilean__EnableDashboard="${Zilean__EnableDashboard:-false}"
export Zilean__Dmm__EnableScraping="${Zilean__Dmm__EnableScraping:-true}"
export Zilean__Dmm__ScrapeSchedule="${Zilean__Dmm__ScrapeSchedule:-0 * * * *}"
export Zilean__Imdb__EnableImportMatching="${Zilean__Imdb__EnableImportMatching:-true}"
export TZ="${TZ:-Etc/UTC}"

# An empty API key is left unset, so zilean generates one on first run and keeps it in /config.
if [[ -z "${Zilean__ApiKey:-}" ]]; then
  unset Zilean__ApiKey
fi

# Path to the libpython shared library used by pythonnet. Resolved at start unless set.
if [[ -z "${ZILEAN_PYTHON_PYLIB:-}" ]]; then
  ZILEAN_PYTHON_PYLIB="$(python3 -c 'import os, sysconfig; print(os.path.join(sysconfig.get_config_var("LIBDIR"), sysconfig.get_config_var("INSTSONAME")))')"
  export ZILEAN_PYTHON_PYLIB
fi

# Read one key from the connection string (case-insensitive), without printing the password.
conn_value() {
  printf '%s' "$Zilean__Database__ConnectionString" | tr ';' '\n' | awk -F= -v key="$1" 'tolower($1) == key { print $2 }' | tail -n1
}

db_host="$(conn_value host || true)"
db_port="$(conn_value port || true)"
db_port="${db_port:-5432}"

# Wait up to 60 seconds for PostgreSQL. After that, start anyway so zilean logs its own error.
if [[ -n "$db_host" ]]; then
  for _ in $(seq 1 60); do
    if timeout 1 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$db_host" "$db_port" 2>/dev/null; then
      break
    fi
    echo "waiting for database at ${db_host}:${db_port}"
    sleep 1
  done
fi

cd /app
exec ./zilean-api "$@"
