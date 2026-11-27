#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"

# persistent state and logs under /config, scratch under /tmp
mkdir -p /config/Data /config/Logs /config/DockerMods /config/common /tmp/dotnet /tmp/nuget

# UNVERIFIED: the Video plugin needs the ffmpeg variable set in the UI, pointing to /usr/bin/ffmpeg
cd /app/fileflows/Server
exec dotnet FileFlows.Server.dll
