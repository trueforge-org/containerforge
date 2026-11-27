#!/usr/bin/env bash
# Starts CodeProject.AI Server. /app stays read-only, so all state goes to /config (or /tmp).
set -euo pipefail

mkdir -p /config/settings /config/modules /config/runtimes \
  /config/downloads/modules/packages /config/downloads/models /config/logs

# Seed the modules and runtimes shipped with the server. cp -n never overwrites user state.
# UNVERIFIED: the server reads these paths through the ModuleOptions__* overrides below.
if [[ -d /app/server/modules ]]; then
  cp -an /app/server/modules/. /config/modules/
fi
if [[ -d /app/server/runtimes ]]; then
  cp -an /app/server/runtimes/. /config/runtimes/
fi

export ASPNETCORE_URLS="${ASPNETCORE_URLS:-http://0.0.0.0:32168}"
export ModuleOptions__ModulesDirPath=/config/modules
export ModuleOptions__RuntimesDirPath=/config/runtimes
export ModuleOptions__DownloadedModulePackagesDirPath=/config/downloads/modules/packages
export ModuleOptions__DownloadedModelsPackagesDirPath=/config/downloads/models
export TMPDIR=/tmp

# UNVERIFIED: logs are written under the install root (LoggingDir "logs"). If the server writes to /app/server/logs,
# this fails on the read-only rootfs. Check the first run.
cd /app/server
exec /app/dotnet/dotnet CodeProject.AI.Server.dll
