# Docker Hub: cglatot/pasta
Source URL(s): https://hub.docker.com/v2/repositories/cglatot/pasta/ , .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- "Batch Audio and Subtitle Track Changer for Plex"; PASTA (Plex Audio & Subtitle Track Automation)
- Pulls 1,573,446; stars 4; status active; last_updated 2026-11-16
- Tags: 41 total. Recent: latest and 3 (2026-11-16, amd64+arm64), 3.0.0 (same day), 2 and 2.3.0 (2026-10-26), 2.2.15 (2026-10-25), 2.2.14 (2026-08-15, amd64+arm64), 2.2.13 to 2.2.11 (amd64 only)
- Chart pins 3.0.0 (digest 8679a66d...)
- Also on ghcr.io/cglatot/pasta:latest (readme)
- Readme links: live web app pastatool.com; Unraid CA template

## Modes
- PASTA_MODE=server (Docker default): web UI + background automation; settings and logs in /config
- PASTA_MODE=client: browser-only, no storage, no background automation

## Install (readme compose example, server mode)
- ports "8080:80"; volume ./appdata:/config
- env: PORT=80, PASTA_MODE=server, PASTA_CONFIG_DIR=/config; optional PASTA_DEBUG, PASTA_SECRET

## Build (see github-pasta-dockerfile.md)
- Stage 1: node:24-alpine (build), npm ci, npm run build (tsc -b && vite build)
- Stage 2: node:24-alpine runtime, copies dist, src/shared, server/src, package.json (no npm install in runtime stage)
- Local arm64 build: docker buildx build --platform linux/arm64 (readme)

## Entrypoint/CMD
- CMD ["node", "--disable-warning=ExperimentalWarning", "server/src/index.ts"]
- WORKDIR /app

## Env vars (image ENV)
| Var | Value |
| --- | --- |
| NODE_ENV | production |
| PORT | 80 |
| PASTA_MODE | server |
| PASTA_CONFIG_DIR | /config |
| PASTA_DIST_DIR | /app/dist |

Optional (readme): PASTA_DEBUG (verbose logs), PASTA_SECRET (fixed secret, else /config/.pasta_secret auto-generated), PASTA_IGNORE (ignore keywords)

## Ports
- EXPOSE 80

## Volumes/paths
- /config created in image (mkdir -p /config); persistent settings, logs, .pasta_secret
- /app/dist: built frontend assets

## User/UID
- No USER directive in Dockerfile: runs as root

## Healthcheck
- none defined

## Arch
- linux/amd64 and linux/arm64 (tags 3.0.0, latest); 2.2.11 to 2.2.13 amd64 only

## Gotchas
- Upgrading to 3.0 adds Server Mode; new /config mount needed (Unraid note)
- Server mode needs Plex server access; optional LAN URL set in Admin Settings
