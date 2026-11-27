# pocket-id Dockerfile (docker/Dockerfile, tag v2.19.3)

## Source URL(s) + date
- https://raw.githubusercontent.com/pocket-id/pocket-id/v2.19.3/docker/Dockerfile (fetched 2026-11-27)
- Blob URL in list points to same file (not fetched separately)

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| frontend-builder | `ghcr.io/voidzero-dev/vite-plus:1.4.0` (BUILDPLATFORM) | copy package.json, pnpm-workspace.yaml, pnpm-lock.yaml, .node-version, frontend/tests/email-templates package.json; `vp -C frontend install --frozen-lockfile --prefer-offline`; `BUILD_OUTPUT_PATH=dist vp -C frontend run build` |
| backend-builder | `golang:1.27.4-alpine` | `go mod download`; copy backend + frontend/dist + .version; `CGO_ENABLED=0 GOOS=linux go build -tags "${BUILD_TAGS}" -trimpath -ldflags="-X github.com/pocket-id/pocket-id/backend/internal/common.Version=${VERSION} -buildid=${VERSION}" -o /build/pocket-id .` (in /build/cmd) |
| final | `alpine:3.24.3` | `apk add --no-cache su-exec`; copy binary to /app/pocket-id; copy scripts/docker to /app/docker; chmod +x |

- ARG BUILD_TAGS (default "")
- Build caches use uid/gid 1000 for vp/pnpm store

## Runtime
- WORKDIR /app
- ENV APP_ENV=production
- EXPOSE 1411
- HEALTHCHECK `--interval=90s --timeout=5s --start-period=10s --retries=3 CMD [ "/app/pocket-id", "healthcheck" ]`
- `ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]`, `CMD ["/app/pocket-id"]`

## User/UID
- No USER directive; entrypoint handles PUID/PGID (see `pocket-id-entrypoint.md`)

## Volumes/paths
- /app (binary, docker scripts), data dir created by entrypoint at /app/data

## Gotchas
- Version pinned via `.version` file in build context
