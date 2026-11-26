# FileFlows docs: Linux installation

Source URL(s) + fetch date:
- https://fileflows.com/docs/installation/linux (fetched 2026-11-26; DNS failed twice before success)

## Install steps (server, as documented)

1. Download archive with wget to `FileFlows.tar.xz`. Download URL: `https://fileflows.com/downloads/tarxz` (the page itself says "No downloads available" in its downloads section; the URL was checked separately in plan section 1).
2. Create a FileFlows folder, extract with `tar -xJf`.
3. `chmod +x run-server.sh`; `./run-server.sh` starts the server with a GUI.
4. No-GUI form: `cd Server` then `dotnet FileFlows.Server.dll`.

Default web interface: `http://localhost:19200/` (port 19200).

## Prerequisites

- Page lists ".NET 10 SDK" (with a link to Microsoft's Linux install guide). Plan uses runtime packages (`dotnet-runtime-10.0`, `aspnetcore-runtime-10.0`); the docs say SDK. Not changed in plan.
- FFmpeg only needed for the Video plugin.

## FFmpeg configuration

- Set a Variable in the web console named `ffmpeg` (case insensitive) with path `/usr/bin/ffmpeg` (or the install location).

## Agent (optional)

- `./run-agent.sh [server-url]` or `dotnet FileFlows.Agent.dll --server <url>`. Example server URL `http://fileflows:19200/`.
- Agent config file: `Data/agent.config` (auto-created on first run; fields ServerUrl, AccessToken, StartMinimized, HostName).

## Data directory

- Page does not name a general server data directory beyond the agent `Data/` folder.

## Gotchas

- The Linux doc's server-data location is not stated, so the plan's `/config/Data` symlink approach stays unverified.
