# Upstream: AlfHou/hammond (Dockerfile, README, release and tags HTML)

## Source URL(s) + date
- https://raw.githubusercontent.com/AlfHou/hammond/c167642b889a7d939e6087d9bda9854d4346ee5c/Dockerfile (fetched 2026-11-27; same file as the api contents and blob URLs)
- https://raw.githubusercontent.com/AlfHou/hammond/master/README.md (fetched 2026-11-27)
- https://github.com/AlfHou/hammond/releases/tag/v0.0.24 (HTML, title "Release v0.0.24 · AlfHou/hammond", fetched 2026-11-27)
- https://github.com/AlfHou/hammond/tags (HTML, fetched 2026-11-27; lists tags such as v0.0.15 to v0.0.19 in the page)

## What it is
- Hammond: self-hosted vehicle expense tracker. Go backend (Gin, GORM, SQLite) and Vue/Buefy frontend. Fork of akhilrex/hammond, now the successor to Clarkson.
- Migration from Clarkson (MySQL DSN) supported on first run.

## Build (Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| builder | `golang:${GO_VERSION}-alpine` (`GO_VERSION=1.20.6`) | `apk add alpine-sdk git`; `WORKDIR /api`; `COPY ./server/go.mod`, `go.sum`; `go mod download`; `COPY ./server .`; `go build -o ./app ./main.go` |
| build-stage | `node:16-alpine` | `WORKDIR /app`; `COPY ./ui/package*.json`; apk build deps (autoconf, automake, build-base, nasm, libc6-compat, python3, py3-pip, make, g++, libpng-dev, zlib-dev, pngquant); `npm install`; `COPY ./ui .`; `npm run build` |
| final | `alpine:latest` | `ca-certificates tzdata`; mkdir `/config /assets /api`; chmod 777 `/config` and `/assets`; `WORKDIR /api`; `COPY --from=builder /api/app .`; `COPY --from=build-stage /app/dist ./dist`; `EXPOSE 3000`; `ENTRYPOINT ["./app"]` |

- Dockerfile source paths: `./server` (Go) and `./ui` (frontend). Go version pinned by `ARG GO_VERSION=1.20.6`.
- Label: `org.opencontainers.image.source=https://github.com/alfhou/hammond`.

## Entrypoint/flags
- `ENTRYPOINT ["./app"]`, no CMD. Working dir `/api`.

## Env vars (Dockerfile ENV)
| Name | Default |
| --- | --- |
| CONFIG | `/config` |
| DATA | `/assets` |
| UID | `998` |
| PID | `100` |
| GIN_MODE | `release` |

- README env table: `JWT_SECRET` (signs JWT; default exists; change it), `PORT` (internal app port; default empty).

## Ports
- `EXPOSE 3000`. README runs `-p 3000:3000`.

## Volumes/paths
- `VOLUME ["/config", "/assets"]`. README binds `/path/to/config:/config` and `/path/to/data:/assets` (compose).

## User/UID
- No USER directive (root). `UID`/`PID` env vars are set but not used by the Dockerfile itself.

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Tag `v0.0.24` (from release HTML page title). Release API and tags API calls returned 403 (see README); HTML release page used instead.
- Image tags on GHCR: `ghcr.io/alfhou/hammond` (chart). Docker Hub: `alfhou/hammond` (README).

## Arch
- Not stated in fetched sources.

## Gotchas
- Final stage is `alpine:latest` (musl). Plan's copy-from note applies.
- Dockerfile uses `node:16-alpine` for the UI and `chmod 777` on `/config` and `/assets`.
- README says the Clarkson migrated users get password `hammond`.
