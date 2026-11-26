# Upstream Dockerfile (MrBrax/LiveStreamDVR @ 1cd7e8f) + helper scripts

## Source URL(s) + date
- https://raw.githubusercontent.com/MrBrax/LiveStreamDVR/1cd7e8fa5b68e6c0cf9e657d1caa2cc74f7eb814/Dockerfile (2026-11-26)
- Merged follow-ups: .../docker/fetch-tdl.sh, .../docker/fetch-ttv-lol.sh (2026-11-26)
- Not fetched (same as raw): https://github.com/MrBrax/LiveStreamDVR/blob/1cd7e8f.../Dockerfile

## Base and build steps (Dockerfile)
- `# syntax=docker/dockerfile:1.4`; `FROM node:20-bullseye-slim`.
- mkdir `/usr/local/share/twitchautomator`, chown/chmod node.
- ARG `IS_DEV`, `BUILD_DATE` -> ENV `IS_DEV`, `VITE_IS_DEV`, `BUILD_DATE`, `VITE_BUILD_DATE`.
- apt: ffmpeg mediainfo python3 python3-pip python3-wheel libxml2-dev libxslt-dev python3-dev bash git curl unzip rclone.
- `pip install pipenv`; COPY `Pipfile Pipfile.lock requirements.txt binaries.txt` -> `/usr/local/share/twitchautomator/`.
- `USER node`: `pipenv install --deploy --ignore-pipfile`; PATH adds `/home/node/.local/bin`.
- `USER root`; apt-remove libxml2-dev libxslt-dev python3-dev; autoremove.
- COPY `common`, `twitch-chat-dumper`: `yarn && yarn build`, remove node_modules and cache.
- COPY `twitch-vod-chat`: `yarn install --immutable && yarn build --base=/vodplayer && yarn buildlib`.
- COPY `server`: `yarn && yarn lint:ts && yarn build && yarn run generate-licenses`.
- COPY `client-vue`: `yarn && yarn build && yarn run generate-licenses`.
- `docker/fetch-tdl.sh` -> `/tmp`, run; ENV `TCD_TWITCHDOWNLOADER_PATH=/usr/local/bin/TwitchDownloaderCLI`.
- `docker/fetch-ttv-lol.sh` -> `/tmp`, run.
- `/home/node` created, chown node; ENV `HOME=/home/node`; fonts from `docker/fonts` into `/home/node/.fonts`.

## Env vars (Dockerfile ENV)
| Name | Value |
| --- | --- |
| TCD_BIN_DIR | /usr/local/bin |
| TCD_FFMPEG_PATH | /usr/bin/ffmpeg |
| TCD_BIN_PATH_PYTHON | /usr/bin/python |
| TCD_BIN_PATH_PYTHON3 | /usr/bin/python3 |
| TCD_MEDIAINFO_PATH | /usr/bin/mediainfo |
| TCD_NODE_PATH | /usr/local/bin/node |
| TCD_DOCKER | 1 |
| TCD_WEBSOCKET_ENABLED | 1 |
| TCD_SERVER_PORT | 8080 |
| TCD_PYTHON_ENABLE_PIPENV | 1 |
| TCD_TWITCHDOWNLOADER_PATH | /usr/local/bin/TwitchDownloaderCLI |
| HOME | /home/node |
| IS_DEV, BUILD_DATE (+VITE_ copies) | build args |

## Entrypoint
- `ENTRYPOINT [ "yarn", "run", "start" ]`; WORKDIR `/usr/local/share/twitchautomator/server`.
- `EXPOSE 8080`.
- USER line commented out: runs as root.

## fetch-tdl.sh (merged)
- `set -euxo pipefail`; `TD_VERSION="1.54.3"`.
- Arch map: x86_64 -> `Linux-x64`; aarch64 -> `LinuxArm64`; armv7l -> `LinuxArm`; else exit.
- Archive: `TwitchDownloaderCLI-${TD_VERSION}-${TD_ARCH}.zip` from `https://github.com/lay295/TwitchDownloader/releases/download/${TD_VERSION}/`.
- unzip; mv to `/usr/local/bin/TwitchDownloaderCLI`; chmod +x.
- Docs: README.md and LICENSE.txt from lay295/TwitchDownloader master -> `/usr/share/doc/twitchdownloader/`.
- No checksum step seen in the script.

## fetch-ttv-lol.sh (merged)
- `set -euxo pipefail`; `INSTALL_DIR=/usr/local/share/twitchautomator/data/streamlink_plugins`.
- `curl -L -o $INSTALL_DIR/twitch.py https://github.com/2bc4/streamlink-ttvlol/releases/latest/download/twitch.py` (unpinned "latest", no checksum).

## Ports
- 8080 (EXPOSE, TCD_SERVER_PORT).

## Gotchas
- Root runtime (USER node commented out).
- Unpinned `latest` download for the streamlink plugin.
- `pipenv install` runs as node; `rclone`, `git`, `unzip` installed.
- Dockerfile uses `docker/fonts` directory; not fetched.
