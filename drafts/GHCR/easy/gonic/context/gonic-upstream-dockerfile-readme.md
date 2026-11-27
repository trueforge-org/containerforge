# Upstream gonic Dockerfile + README (v0.23.0)

## Source URL(s) + date

- https://raw.githubusercontent.com/sentriz/gonic/v0.23.0/Dockerfile
- https://raw.githubusercontent.com/sentriz/gonic/v0.23.0/README.md
- Fetched 2026-11-27

## What it is

- Subsonic-API music server (Go), SQLite-backed. Features: tag browsing (taglib), podcasts, multi-user, jukebox (mpv), web config UI.

## Build (Dockerfile)

- Stage `builder`: `--platform=$BUILDPLATFORM golang:1.27-alpine3.24`, `ARG TARGETOS`, `ARG TARGETARCH`.

  - `COPY go.mod`, `go.sum`; `go mod download`; `COPY . .`.
  - `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/ ./cmd/...`
  - Cache mounts: `/go/pkg/mod`, `/root/.cache/go-build`.

- Final stage: `alpine:3.24`, label `org.opencontainers.image.source=https://github.com/sentriz/gonic`.

  - `apk add -U --no-cache ffmpeg mpv ca-certificates tzdata tini shared-mime-info`.
  - `COPY --from=builder /out/* /usr/local/bin/`.

## Runtime deps

- ffmpeg, mpv (jukebox), ca-certificates, tzdata, tini, shared-mime-info.

## Entrypoint/flags

- `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["gonic"]`.
- Binaries in `/usr/local/bin/` (cmd/... output; `gonic` is the server).

## Env vars (image defaults)

| Var | Default |
| --- | --- |
| TZ | empty |
| GONIC_DB_PATH | `/data/gonic.db` |
| GONIC_LISTEN_ADDR | `:80` |
| GONIC_MUSIC_PATH | `/music` |
| GONIC_PODCAST_PATH | `/podcasts` |
| GONIC_CACHE_PATH | `/cache` |
| GONIC_PLAYLISTS_PATH | `/playlists` |

## Env vars (README, v0.23.0; flag equivalent in parentheses)

| Var | Flag | Notes |
| --- | --- | --- |
| GONIC_MUSIC_PATH | -music-path | music dir; comma-separated multi-folder, optional `alias->path` |
| GONIC_PODCAST_PATH | -podcast-path | podcasts dir |
| GONIC_PLAYLISTS_PATH | -playlists-path | m3u files as `<userid>/<name>.m3u` |
| GONIC_CACHE_PATH | -cache-path | transcodes, covers |
| GONIC_DB_PATH | -db-path | optional DB file |
| GONIC_HTTP_LOG | -http-log | on by default |
| GONIC_LISTEN_ADDR | -listen-addr | default `0.0.0.0:4747` |
| GONIC_TLS_CERT / GONIC_TLS_KEY | -tls-cert / -tls-key | enables HTTPS |
| GONIC_PROXY_PREFIX | -proxy-prefix | e.g. `/gonic` |
| GONIC_SCAN_INTERVAL | -scan-interval | minutes; auto-scan off if omitted |
| GONIC_SCAN_AT_START_ENABLED | -scan-at-start-enabled | initial scan |
| GONIC_SCAN_WATCHER_ENABLED | -scan-watcher-enabled | fs watch |
| GONIC_SCAN_EMBEDDED_COVER_ENABLED | -scan-embedded-cover-enabled | default true |
| GONIC_JUKEBOX_ENABLED | -jukebox-enabled | subsonic jukebox API |
| GONIC_JUKEBOX_MPV_EXTRA_ARGS | -jukebox-mpv-extra-args | mpv args |
| GONIC_PODCAST_PURGE_AGE | -podcast-purge-age | days |
| GONIC_EXCLUDE_PATTERN | -exclude-pattern | regex of files to skip |
| GONIC_MULTI_VALUE_GENRE / _ARTIST / _ALBUM_ARTIST / _ISRC | matching flags | multi-valued tags (v0.16+) |
| GONIC_TRANSCODE_CACHE_SIZE | -transcode-cache-size | MB, 0 = no limit |
| GONIC_TRANSCODE_EJECT_INTERVAL | -transcode-eject-interval | minutes, 0 = never |
| GONIC_EXPVAR | -expvar | enables /debug/vars |

## Ports

- EXPOSE 80 (image default `:80`); README default 4747.

## Volumes/paths

- Image `VOLUME ["/cache", "/data", "/music", "/podcasts"]`.
- `/playlists` is set by ENV but not declared as VOLUME.

## User/UID

- Image sets no USER (runs as root).

## Healthcheck

- None.

## Gotchas

- Image default listen port 80 vs README default 4747.
- Multi-folder music path: comma-separated list, optional `alias->path` (README; from v0.15+).
- Upstream image installs ffmpeg and mpv; README does not state which features need them (not verified).
