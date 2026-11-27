# Upstream: TwiN/gatus Dockerfile, go.mod, README, release tag

## Source URL(s) + date
- https://raw.githubusercontent.com/TwiN/gatus/d255d0cd4d69ce818574cfdb3a7e82407e6559d7/Dockerfile (fetched 2026-11-27; the draft's pinned commit, same content as the api contents and blob URLs)
- https://raw.githubusercontent.com/TwiN/gatus/d255d0cd4d69ce818574cfdb3a7e82407e6559d7/go.mod (fetched 2026-11-27)
- https://raw.githubusercontent.com/TwiN/gatus/master/README.md (fetched 2026-11-27)
- https://github.com/TwiN/gatus/releases/tag/v5.38.0 (HTML, title "Release v5.38.0 · TwiN/gatus"; release assets not read here, plan notes zero assets)

## What it is
- Gatus: health/uptime monitoring service with status page, configured by YAML. Written in Go.

## Build (Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| builder | `golang:alpine` | `apk add ca-certificates`, `WORKDIR /app`, `COPY . ./`, `go mod tidy -diff`, `CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gatus .` |
| final | `scratch` | `COPY --from=builder /app/gatus .`, `COPY --from=builder /app/config.yaml ./config/config.yaml`, CA bundle `/etc/ssl/certs/ca-certificates.crt` |

- Go toolchain: `go 1.26.3` (go.mod). No `toolchain` line.
- Test step is commented out in the Dockerfile.

## Entrypoint/flags
- `ENTRYPOINT ["/gatus"]`, no CMD. No shell in image (scratch).

## Env vars (Dockerfile ENV)
| Name | Default |
| --- | --- |
| GATUS_CONFIG_PATH | "" (empty) |
| GATUS_LOG_LEVEL | "INFO" |
| PORT | "8080" |

## Ports
- `EXPOSE ${PORT}` (8080).

## Volumes/paths
- Binary at `/gatus`. Default config at `/config/config.yaml` (copied from repo `config.yaml`; WORKDIR not set so relative to `/`).
- No VOLUME.

## User/UID
- No USER. Scratch base: runs as root unless overridden.

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Tags `v5.38.0` (tag has `v`). Chart tag `v5.38.0`. Bake VERSION without `v` per plan.
- Release checksum: not checked in this fetch (only the HTML title was read).
- Plan notes the release has zero assets (API response, earlier). API call for release this session returned 403, see README.

## Arch
- Pure Go, `CGO_ENABLED=0`: amd64 and arm64 buildable from the same source.

## Gotchas
- Final image is `scratch`: no shell, no `apk`, no package manager. Copy CA bundle as shown.
- `go mod tidy -diff` runs in build; requires module graph to be consistent.
- README quick start: `docker run -p 8080:8080 --name gatus ghcr.io/twin/gatus:stable`; also `twinproduction/gatus` on Docker Hub (mirror, not fetched).
