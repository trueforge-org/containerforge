# Upstream homebox Dockerfile + release assets

## Source URL(s) + date

- https://raw.githubusercontent.com/sysadminsmedia/homebox/main/Dockerfile
- https://raw.githubusercontent.com/sysadminsmedia/homebox/1fd28822634a3d5935c002d569559ef46530d4a0/Dockerfile (identical to main; diffed)
- https://api.github.com/repos/sysadminsmedia/homebox/releases/latest (tag v0.27.1, published 2026-10-23T18:27:49Z)
- https://homebox.software/en (landing page only; no install/config content)
- Fetched 2026-11-27

## Build (Dockerfile, multi-stage)

- Stage `frontend-dependencies`: `mirror.gcr.io/library/node:22-alpine`; `npm install -g pnpm@10`; `pnpm install --frozen-lockfile` (frontend/).
- Stage `frontend-builder`: `pnpm build` (Nuxt) -> `/app/.output/public`.
- Stage `builder-dependencies`: `mirror.gcr.io/library/golang:alpine`; `go mod download` (backend/).
- Stage `builder`: `mirror.gcr.io/library/golang:alpine`; ARGs `TARGETOS TARGETARCH BUILD_TIME COMMIT VERSION`.

  - apk: git, build-base, gcc, g++ (plus libwebp libavif libheif libjxl on most arches).
  - Frontend output copied to `./app/api/static/public`.
  - `CGO_ENABLED=0 go build -ldflags "-s -w -X main.commit=... -X main.buildTime=... -X main.version=..." -o /go/bin/api ./app/api/*.go`. arm/riscv64 build adds `-tags nodynamic`.

- Final stage: `mirror.gcr.io/library/alpine:latest`.

  - apk: ca-certificates, wget, mosquitto-clients (+ libwebp libavif libheif libjxl on most arches).
  - `/app/api` copied from builder; `chmod +x`.

## Entrypoint / CMD

- `ENTRYPOINT ["/app/api"]`, `CMD ["/data/config.yml"]`. `WORKDIR /app`.

## Env (image ENV)

| Var | Value |
| --- | --- |
| HBOX_MODE | `production` |
| HBOX_STORAGE_CONN_STRING | `file:///?no_tmp_dir=true` |
| HBOX_STORAGE_PREFIX_PATH | `data` |
| HBOX_DATABASE_SQLITE_PATH | `/data/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite` |

## Ports / healthcheck

- `EXPOSE 7745`.
- `HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD wget --no-verbose --tries=1 -O - http://localhost:7745/api/v1/status`.

## Volumes

- `VOLUME ["/data"]`.

## Labels

- `org.opencontainers.image.source=https://github.com/sysadminsmedia/homebox`; `Name=homebox Version=0.0.1` (stale label).

## Release assets (v0.27.1)

- `homebox_Linux_x86_64.tar.gz`, `homebox_Linux_arm64.tar.gz`, `homebox_Linux_riscv64.tar.gz` (+ `.sbom.json` each).
- `checksums.txt` at `https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/checksums.txt`.
- Other OS builds: Darwin, Freebsd, and more (not used).

## Gotchas

- Dockerfile on main and pinned commit are identical.
- Upstream CMD expects `/data/config.yml`; whether the binary runs without it is not confirmed by these sources.
- Image base is alpine (musl), but release binary linkage was not checked.
