# mescon/Muximux upstream Dockerfile + release

Source URL(s) + date: https://raw.githubusercontent.com/mescon/Muximux/main/Dockerfile ; https://api.github.com/repos/mescon/Muximux/releases/latest (fetched 2026-11-27)
License: GPL-2.0 (https://raw.githubusercontent.com/mescon/Muximux/main/LICENSE, GNU GPL v2 June 1991)

## What it is
- Go backend with embedded Node-built frontend (`-tags embed_web`), single binary `/muximux`.

## Build stages
| Stage | Base | Notes |
| --- | --- | --- |
| frontend | node:26-alpine (--platform=$BUILDPLATFORM) | WORKDIR /app/web; `npm ci --no-audit --ignore-scripts`; `npm run build` |
| backend | golang:1.27-alpine (--platform=$BUILDPLATFORM) | `apk add git`; `go mod download`; copies cmd/, internal/, frontend dist to internal/server/dist |
| final | alpine:3.24 | WORKDIR /app |

- Backend build: `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -tags embed_web -ldflags "-s -w -X main.version=... -X main.commit=... -X main.buildDate=..." -o /muximux ./cmd/muximux`
- Build ARGs: BUILDPLATFORM, TARGETPLATFORM, TARGETOS, TARGETARCH (no defaults); VERSION=dev, COMMIT=none, BUILD_DATE=unknown.

## Final image
- `apk add --no-cache ca-certificates shadow su-exec tzdata wget && mkdir -p /app/data`
- COPY `--from=backend /muximux ./muximux`; COPY `docker-entrypoint.sh /docker-entrypoint.sh`; chmod +x.
- ENTRYPOINT `["/docker-entrypoint.sh"]`
- CMD `["./muximux", "--data", "/app/data"]`
- EXPOSE 8080; VOLUME /app/data

## Env vars
| Name | Default | Purpose |
| --- | --- | --- |
| PUID | 1000 | linuxserver-style uid for bind mounts (via shadow/su-exec) |
| PGID | 1000 | linuxserver-style gid |
| XDG_DATA_HOME | /app/data | data dir |

## Volumes / paths
- /app/data (data volume); binary at /muximux (root-level, not /app).

## User/UID
- No USER instruction. Entrypoint uses PUID/PGID with su-exec. HOME noted as /app.

## Healthcheck
- `wget -qO- http://localhost:8080/api/health || exit 1`, interval 30s, timeout 10s, start-period 10s, retries 3.

## Version / asset naming (GitHub release)
- Latest tag: v3.7.4 (published 2026-11-24).
- Assets: checksums.txt, muximux-linux-amd64, muximux-linux-arm64, muximux-darwin-amd64, muximux-darwin-arm64, muximux-windows-amd64.exe, muximux-sbom.spdx.json.

## Arch
- Build is multi-platform via TARGETOS/TARGETARCH; release binaries exist for linux amd64/arm64.

## Gotchas
- Upstream image itself is GHCR-published (ghcr.io/mescon/muximux); chart pins it.
- Chart runs as root (runAsUser 0), upstream relies on PUID/PGID rather than USER.
- Base images pinned to node:26, golang:1.27, alpine:3.24 at fetch time.
