# solidping upstream Dockerfile (commit 5e35c5e)

## Source URL(s) + date
- https://raw.githubusercontent.com/fclairamb/solidping/5e35c5e4a02b63f3e15c48ade8e6bbe4b5b4e070/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27. v0.54.1 Dockerfile not fetched (plan notes it as unverified).

## Stages
- `FROM --platform=$BUILDPLATFORM node:26-alpine AS dash0-builder`
- `FROM --platform=$BUILDPLATFORM node:26-alpine AS status0-builder`
- `FROM --platform=$BUILDPLATFORM node:26-alpine AS docs-builder`
- `FROM --platform=$BUILDPLATFORM golang:1.27.4-trixie AS backend-deps`; `FROM backend-deps AS backend-builder`
- final `FROM gcr.io/distroless/base-debian13:nonroot`
- Node stages: apk `curl unzip bash`; bun installed via curl; `bun install --frozen-lockfile`; `bun run build`
- Go: `go mod download`; `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build` with `-X` for `internal/version.Version/Commit/GitTime`, output `/solidping`
- `mkdir -p /data/files`

## ARG
- `VERSION=dev`, `COMMIT=unknown`, `GIT_TIME=unknown`, `TARGETOS`, `TARGETARCH` (no defaults)

## ENV
- `SP_DB_TYPE=sqlite`, `SP_DB_DIR=/data`, `SP_FILESTORAGE_LOCAL_ROOT=/data/files`

## Runtime
- COPY `--from=backend-builder /solidping /app/solidping`
- COPY `--from=backend-builder --chown=65532:65532 /data /data`
- WORKDIR `/app`
- VOLUME `/data`; EXPOSE `4000`
- ENTRYPOINT `["/app/solidping", "serve"]`; no CMD
- HEALTHCHECK `--interval=30s --timeout=5s --start-period=20s --retries=3 CMD ["/app/solidping", "healthcheck"]`
- No USER line; no user/group created. Distroless `nonroot` base runs as UID/GID 65532.

## Gotchas
- Health path `/api/mgmt/health` is referenced by TrueCharts probes (not seen in Dockerfile fetch summary).
