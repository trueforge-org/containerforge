# sbondCo/Watcharr Dockerfile @ v4.4.0

Source URL(s): https://raw.githubusercontent.com/sbondCo/Watcharr/v4.4.0/Dockerfile (fetched 2026-11-27, 46 lines)

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| server | golang:1.27-alpine | COPY server/ ; apk musl-dev gcc build-base; `GOOS=linux CGO_ENABLED=1 CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ./watcharr` (go-sqlite3 needs cgo) |
| ui | node:24-alpine | COPY package*.json, vite.config.ts, svelte.config.js, tsconfig.json, src/, static/; `npm install && npm run build` -> /app/build |
| runner | node:24-alpine | binary -> `/watcharr`; build -> `/ui`; package.json + package-lock.json -> /ui/; `npm ci --omit=dev --ignore-scripts=true` in /ui |

## Entrypoint / Ports
- `EXPOSE 3080`; `CMD ["/watcharr"]` (no ENTRYPOINT, no USER, no VOLUME, no HEALTHCHECK).

## Runtime layout
- Server binary at `/watcharr` (cwd `/`), frontend assets served from `/ui`.
- Runtime data: backup doc says data lives in `./data` (watcharr.db, watcharr.db-wal). With cwd `/`, that is `/data` (matches chart mount).

## Env vars
- None set in Dockerfile. Chart maps MODE, JWT_SECRET, SIGNUP_ENABLED, DEBUG, TMDB_KEY, JELLYFIN_HOST (see truecharts-watcharr.md). Full list in upstream docs (env var page not fetched).

## User/UID
- Not set: runs as root.

## Gotchas
- Node 24 runtime (node:24-alpine) carries npm; prod deps installed in /ui.
- Go 1.27 and node 24 versions are upstream-pinned in this tag.
