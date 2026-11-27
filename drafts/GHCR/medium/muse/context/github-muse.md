# Upstream: museofficial/muse (v2.12.0)

Source URL(s) + date: https://raw.githubusercontent.com/museofficial/muse/v2.12.0/Dockerfile ; https://raw.githubusercontent.com/museofficial/muse/v2.12.0/README.md (fetched 2026-11-27)

## What it is
- Discord music bot, TypeScript/Node.js, Prisma, yarn. Community-maintained under `museofficial` org.
- README: GHCR `ghcr.io/museofficial/muse` is the canonical image; Docker Hub tags may be mirrors.
- README: Node.js 22.12.0+ required for non-Docker run; 64-bit OS required.

## Dockerfile (v2.12.0) build
- Stages: `base` -> `dependencies` -> `builder` -> `runner` (final `FROM base`).
- Base: `FROM node:22-bookworm-slim AS base`.
- base stage: apt installs `ffmpeg tini openssl ca-certificates python3 python3-venv`; creates venv `/opt/yt-dlp`; pip installs `yt-dlp[default]` (pinned if build-arg `YT_DLP_VERSION` non-empty, else unpinned); symlink `/usr/local/bin/yt-dlp`.
- ENV `MUSE_BUNDLED_YT_DLP_PATH=/opt/yt-dlp/bin/yt-dlp`.
- dependencies stage: apt installs `python-is-python3 build-essential`; WORKDIR /usr/app; COPY package.json, yarn.lock; `yarn install --prod` (copied to /usr/app/prod_node_modules), then `yarn install` (full).
- builder: COPY . ; `yarn prisma generate`; `yarn build` (tsc -> dist).
- runner: WORKDIR /usr/app; copies dist, prod node_modules, `.prisma/client`; COPY . .
- Build ARGs: `COMMIT_HASH` (default unknown), `BUILD_DATE` (default unknown), `YT_DLP_VERSION` (default empty).

## Runtime
- CMD: `["tini", "--", "node", "--enable-source-maps", "dist/scripts/migrate-and-start.js"]`
- ENV: DATA_DIR=/data, NODE_ENV=production, ENV_FILE=/config, COMMIT_HASH, BUILD_DATE.
- No USER directive (runs as root by default). No EXPOSE. No HEALTHCHECK.

## Env vars (README)
| Var | Required | Notes |
| --- | --- | --- |
| DISCORD_TOKEN | yes | Discord bot token |
| YOUTUBE_API_KEY | yes | YouTube Data API key |
| SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET | optional | enable Spotify URL conversion |
| YT_DLP_COOKIES_PATH | optional | e.g. /run/secrets/youtube-cookies.txt |
| YT_DLP_PATH | optional (non-Docker) | full path to yt-dlp |
| ENV_FILE | optional | env file path, default /config |

## Ports / volumes
- Ports: none (bot, no listener).
- Volume: `/data` (README compose example `./muse:/data`).

## Tags (README)
- `:2`, `:2.1`, `:2.1.1`, `:latest`, `:yt-dlp-latest` (rebuild with newest yt-dlp).

## Version/asset naming
- Git tags `vX.Y.Z` (e.g. v2.12.0). No release assets needed; image built from source.

## Gotchas
- Discord bot needs View Channel, Send Messages, Embed Links, Read Message History permissions.
- Reuse same `/data` volume and DISCORD_TOKEN to keep bot identity and DB/cache.
- Optional YouTube cookies mounted read-only under /run/secrets.
- `master` branch is unstable; README recommends tagged releases.
- Main-branch README URL returned 404; used the v2.12.0 tag README instead.
