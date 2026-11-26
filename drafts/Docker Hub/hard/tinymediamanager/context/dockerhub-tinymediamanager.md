# Docker Hub: tinymediamanager/tinymediamanager

**Source URL(s):** https://hub.docker.com/r/tinymediamanager/tinymediamanager
**Fetched:** 2026-11-26

## What it is
Official tinyMediaManager Docker image (described as experimental). Built on Debian Buster for compatibility; bundles current libmediainfo and FFmpeg. Gives remote access through noVNC (web) or VNC.

## Tags and architectures
- Tag `latest` (digest begins `sha256:26e80b1b1…`), updated 27 days before the snapshot.
- Architecture: x86_64 only. No arm64 listed.
- Size 658.3 MB; 5M+ pulls.

## Ports
- 4000 (noVNC web). 5900 (VNC, when direct VNC is allowed). HTTP API port (v4.3+) must be mapped too, number not given.

## Env vars
USER_ID (1000), GROUP_ID (1000), PASSWORD (none), LC_TIME (`en_US.UTF-8` 12h, `C.UTF-8` 24h), TZ, ALLOW_DIRECT_VNC (false). Compose sample also sets LC_ALL and LANG to `en_US.UTF-8`.

## Volumes
- `/data`: all data (data, logs, cache, backups). Required on upgrade.
- `/media/xxx` (e.g. `/media/movies`, `/media/tvshows`): media sources, read/write.
- `/app/addons`: custom scrapers. Overview also mentions `/data/addons`.
- `/app/launcher-extra.yml`: custom start parameters.

## User
Runs as USER_ID/GROUP_ID.

## Run example
Ports 4000 and 5900; env LC_ALL, LANG, ALLOW_DIRECT_VNC=true; volumes `/data`, `/media/movies`, `/media/tvshows`, `/app/addons`; json-file logs max 20m x 5. Then open `http://<host>:4000`. Pull: `docker pull tinymediamanager/tinymediamanager`.

## Source links
No Dockerfile or GitHub link on the page. Documentation link: https://www.tinymediamanager.org/docs/start-parameters
