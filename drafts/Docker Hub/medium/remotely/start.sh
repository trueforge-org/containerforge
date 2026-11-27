#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Keep the SQLite database on the persistent volume. The default in appsettings.json is a
# relative path, which would write into /app (read-only at runtime).
export Remotely_ConnectionStrings__SQLite="Data Source=/config/Remotely.db"

cd /app
exec dotnet Remotely_Server.dll
