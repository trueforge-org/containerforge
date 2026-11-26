# doitandbedone/ispyagentdvr-docker Dockerfile (tag 7.1.8.0)

Source URL(s): https://raw.githubusercontent.com/doitandbedone/ispyagentdvr-docker/7.1.8.0/Dockerfile (blob: https://github.com/doitandbedone/ispyagentdvr-docker/blob/7.1.8.0/Dockerfile). Fetched 2026-11-26.

## Base / ARG / ENV
- `FROM ubuntu:22.04`
- ARG: `FILE_LOCATION` default = iSpy Agent zip Linux64 7.1.8.0 at `files.ispyconnect.com/downloads`; `DEBIAN_FRONTEND=noninteractive`; `TZ=America/Los_Angeles`; `name` (no default)
- ENV: `FILE_LOCATION_SET` (true when FILE_LOCATION non-empty); `DEFAULT_FILE_LOCATION` = `https://www.ispyconnect.com/api/Agent/DownloadLocation4?platform=Linux64&fromVersion=0`; `MALLOC_TRIM_THRESHOLD_=100000`

## RUN steps
- apt: wget, unzip, software-properties-common, alsa-utils, apt-transport-https, libxext-dev, fontconfig, libva-drm2
- Agent download: if FILE_LOCATION_SET then wget FILE_LOCATION else query DownloadLocation4 API and wget the returned URL -> agent.zip; unzip into `/agent`; remove zip
- apt: libgdiplus (smart detection)
- `mkdir -p /agent/ffmpeg7`; wget `https://ispyrtcdata.blob.core.windows.net/downloads/ffmpeg7-linuxx64.tar.xz`; `tar -xvf --strip-components=1` into `/agent/ffmpeg7`
- apt: tzdata, curl (Commands external webservice calls)
- Cleanup: purge unzip, wget, build-essential; autoremove; apt-get clean; rm `/var/lib/apt/lists/*`
- `chmod +x` on `/agent/Agent`, `/agent/agent-register.sh`, `/agent/agent-reset.sh`, `/agent/agent-reset-local-login.sh`

## Entrypoint / ports / volumes
- `CMD ["/agent/Agent"]`, no ENTRYPOINT, no USER (runs as root)
- EXPOSE: 8090 (web UI), 3478/udp (STUN), 50000-50100/udp (TURN range)
- VOLUME: `/agent/Media/XML`, `/agent/Media/WebServerRoot/Media`, `/agent/Commands`
- No HEALTHCHECK, no LABEL, no COPY/WORKDIR

## Config notes
- TURN ports via Config.xml elements `TurnServerPort` (3478), `TurnServerMinPort` (50000), `TurnServerMaxPort` (50010 default in comments)
- Server port override: `port.txt` in root dir
- UI must be reached via host LAN IP, not localhost
