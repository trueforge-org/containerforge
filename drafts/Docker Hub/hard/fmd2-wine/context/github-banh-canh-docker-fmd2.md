# GitHub: Banh-Canh/docker-FMD2 (upstream Dockerfile of the chart's image)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/Banh-Canh/docker-FMD2/blob/master/Dockerfile (via raw `master/Dockerfile`)
- https://github.com/Banh-Canh/docker-FMD2 (README via raw `master/README.md`)

## Status

- README: repo is ARCHIVED and no longer maintained. Points to a fork https://github.com/ElryGH/docker-FMD2 (linked only, not fetched).

## What it is

- Containerized FMD2 running the Windows app under Wine, GUI via VNC + noVNC + webSocketify in a browser. Headless.
- Image per README compose: `banhcanh/docker-fmd2:kasm-v3`.

## Dockerfile (verbatim facts)

- `FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`
- `ARG FMD2_VERSION="2.0.32.0"` (pin; chart's image is `latest`, not this)
- `ENV WINEDLLOVERRIDES="mscoree,mshtml="` and `ENV HOME=/config`
- RUN (one chained step):
  - `apt update`; `apt install -y dpkg`; `dpkg --add-architecture i386`
  - `apt install -y wine64=9.0~repack-4build3 wget p7zip-full curl git python3-pyxdg inotify-tools rsync`
  - download: `curl -s https://api.github.com/repos/dazedcat19/FMD2/releases/tags/${FMD2_VERSION}` then grep `browser_download_url.*download.*fmd.*x86_64.*.7z`, then `wget` to `FMD2.7z`
  - `7z x FMD2.7z -o/app/FMD2`; `rm FMD2.7z`; `apt autoremove -y p7zip-full wget curl --purge`
  - `mkdir /downloads`; `mkdir -p /app/FMD2/userdata /app/FMD2/downloads`
- `COPY settings.json root /`
- `VOLUME /config`; `EXPOSE 3000`
- No ADD, USER, WORKDIR, ENTRYPOINT, CMD or HEALTHCHECK. Other apt packages unpinned.
- Note: only `wine64` is installed; `wine32:i386` (plan) is NOT installed upstream.
- LABEL maintainer present (not copied).

## Compose (README)

- `image: banhcanh/docker-fmd2:kasm-v3`
- Env: `PUID=1000`, `PGID=1000`, `TZ=Europe/Paris`, `UMASK=022` (optional), `THRESHOLD_MINUTES=5`, `TRANSFER_FILE_TYPE=.cbz` (the last two unexplained)
- Ports: `3000:3000` (web UI)
- Volumes: `./tmp/FMD2/userdata:/app/FMD2/userdata`, `./tmp/downloads:/downloads`
- No `docker run` command on the page.

## Ports

- 3000 (KasmVNC web UI in upstream). Matches plan's 3000 choice.

## Volumes/paths

- `/config` (VOLUME), `/app/FMD2/userdata`, `/app/FMD2/downloads`, `/downloads`.

## Version/asset naming

- FMD2 is installed by querying the GitHub API for tag `${FMD2_VERSION}` and selecting an asset matching `fmd.*x86_64.*.7z`. Asset name pattern: `fmd_<version>_x86_64-win64.7z`.

## Gotchas

- Upstream pins 2.0.32.0; plan targets 2.0.34.5.
- Upstream runs under KasmVNC/Linuxserver base with PUID/PGID handling; the plan's `apps` user (kasmvnc base) differs.
- README and Dockerfile show `kasm-v3` tag; chart uses `latest`.
