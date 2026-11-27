# Tzahi12345/YoutubeDL-Material Dockerfile @ 58f4313e500cfcb17aa801934163f474e7be6172

Source URL(s): https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/58f4313e500cfcb17aa801934163f474e7be6172/Dockerfile (fetched 2026-11-27); backend/entrypoint.sh at same commit; https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/v4.3.2/backend/package.json and .../v4.3.2/docker-compose.yml (fetched 2026-11-27). (The root-level entrypoint.sh raw URL returned 404; the backend one was used.)

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| utils | ubuntu:22.04 | docker-utils/*.sh: ffmpeg-fetch.sh, fetch-twitchdownloader.sh (produces /usr/local/bin/ffmpeg, ffprobe, TwitchDownloaderCLI) |
| base | ubuntu:22.04 | user youtube (UID/GID 1000); apt curl ca-certificates tzdata libicu70 libatomic1; nvm v0.39.5; Node 16.14.2 |
| frontend | node:16 (BUILDPLATFORM) | @angular/cli, npm install, `npm run build` -> /build/backend/public |
| backend | base | COPY backend/ -> /app; `npm install --prod` (strict-ssl false) |
| final | base | pm2 global; apt gosu, python3-minimal, python-is-python3, python3-pip, atomicparsley, build-essential (removed); pip pycryptodomex |

- Python GetTwitchDownloader step is commented out in the Dockerfile.

## Runtime
- ENV UID=1000, GID=1000, USER=youtube, NO_UPDATE_NOTIFIER=true, PM2_HOME=/app/pm2, ALLOW_CONFIG_MUTATIONS=true, npm_config_cache=/app/.npm, NODE_VERSION=16.14.2.
- WORKDIR /app; public frontend -> /app/public; ffmpeg/ffprobe/TwitchDownloaderCLI copied to /usr/local/bin.
- `chmod +x /app/fix-scripts/*.sh`.
- EXPOSE **17442**.
- `ENTRYPOINT ["/app/entrypoint.sh"]`, `CMD ["npm","start"]`.
- VOLUME line commented out.

## entrypoint.sh (backend/entrypoint.sh)
- `find . ! -user $UID -exec chown $UID:$GID` on cwd (warning on failure).
- `exec gosu "$UID:$GID" "$@"`.
- Needs root start to chown/gosu.

## package.json (v4.3.2, backend)
- name backend, version 1.0.0 (not the release tag), engines node ^16, npm 6.14.4.
- scripts.start: `pm2-runtime --raw pm2.config.js`.

## docker-compose.yml (v4.3.2)
- Port map `8998:17442`; env ytdl_mongodb_connection_string, ytdl_use_local_db=false, write_ytdl_config=true; volumes ./appdata, ./audio, ./video, ./subscriptions, ./users -> /app/*. Image `tzahi12345/youtubedl-material:latest`. Mongo 4 sidecar.

## Ports
- 17442/tcp (EXPOSE); app port setting `ytdl_port` (chart sets 10253); app.js port logic not verified.

## User/UID
- Final image has user youtube (1000:1000) from base; entrypoint runs as root first.

## Healthcheck
- None.

## Gotchas
- Node 16.14.2 (EOL), Ubuntu 22.04, pm2, nvm: old stack.
- Build uses frontend on BUILDPLATFORM node 16 and fetches ffmpeg/TwitchDownloader via utils stage.
