# Upstream Dockerfile: ddns-updater v2.10.0

Source URL(s):
- https://raw.githubusercontent.com/qdm12/ddns-updater/v2.10.0/Dockerfile (fetched 2026-11-27)

## What it is
- Multi-stage build: Go binary built in `golang:<GO_VERSION>-alpine<ALPINE_VERSION>` (defaults GO_VERSION=1.26, ALPINE_VERSION=3.23), final image `FROM scratch`.
- Build tools from `ghcr.io/qdm12/xcputranslate:v0.9.0`, `binpot:golangci-lint-v2.11.4`, `binpot:mockgen-v0.6.0`. Build-only, not runtime.

## Build steps (build stage)
- `CGO_ENABLED=0`, `go mod download`, copy `pkg/ cmd/ internal/`.
- `GOARCH` and `GOARM` from `xcputranslate translate -targetplatform ${TARGETPLATFORM}`.
- `go build -trimpath -ldflags="-s -w -X main.version=... -X main.date=... -X main.commit=..." -o app cmd/ddns-updater/main.go`.
- Build stage creates `/tmp/data`, copied to `/updater/data`.
- Test/lint/mocks stages exist (not runtime).

## Runtime deps
- None. `FROM scratch`, static binary, no shell.

## Entrypoint/flags
- ENTRYPOINT `["/updater/ddns-updater"]`, no CMD.
- HEALTHCHECK `--interval=60s --timeout=5s --start-period=10s --retries=2 CMD ["/updater/ddns-updater", "healthcheck"]`.

## Env vars (Dockerfile defaults)
| Name | Default | Note |
| --- | --- | --- |
| CONFIG | (empty) | one-line JSON, overrides config.json |
| PERIOD | 5m | |
| UPDATE_COOLDOWN_PERIOD | 5m | |
| PUBLICIP_FETCHERS | all | |
| PUBLICIP_HTTP_PROVIDERS | all | |
| PUBLICIPV4_HTTP_PROVIDERS | all | |
| PUBLICIPV6_HTTP_PROVIDERS | all | |
| PUBLICIP_DNS_PROVIDERS | all | |
| PUBLICIP_DNS_TIMEOUT | 3s | |
| HTTP_TIMEOUT | 10s | |
| DATADIR | /updater/data | |
| CONFIG_FILEPATH | /updater/data/config.json | |
| RESOLVER_ADDRESS | (empty) | |
| RESOLVER_TIMEOUT | 5s | |
| SERVER_ENABLED | yes | web UI |
| LISTENING_ADDRESS | :8000 | web UI port |
| ROOT_URL | / | |
| BACKUP_PERIOD | 0 | |
| BACKUP_DIRECTORY | /updater/data | |
| LOG_LEVEL | info | |
| LOG_CALLER | hidden | |
| SHOUTRRR_ADDRESSES | (empty) | |
| SHOUTRRR_DEFAULT_TITLE | "DDNS Updater" | |
| TZ | (empty) | |
| UMASK | (empty) | defaults to OS umask |
| HEALTH_SERVER_ADDRESS | 127.0.0.1:9999 | |
| HEALTH_HEALTHCHECKSIO_BASE_URL | https://hc-ping.com | |
| HEALTH_HEALTHCHECKSIO_UUID | (empty) | |

## Ports
- EXPOSE 8000.

## Volumes/paths
- WORKDIR `/updater`. Binary `/updater/ddns-updater`. Data dir `/updater/data` (owned by UID:GID).

## User/UID
- `ARG UID=1000`, `ARG GID=1000`, `USER ${UID}:${GID}`. Build-arg overridable.

## Version/asset naming
- Release assets: `ddns-updater_<ver>_<os>_<arch>` (no `v`), e.g. `ddns-updater_2.10.0_linux_amd64`, `linux_arm64`, `linux_armv5/6/7`, `linux_386`.

## Arch
- Build uses `TARGETPLATFORM` via xcputranslate; release assets cover linux amd64, arm64, armv5/6/7, 386.

## Gotchas
- Scratch image: no shell, no `/etc/passwd`. Runs as numeric UID; no `USER` name lookup needed.
- Healthcheck binary subcommand is `healthcheck`; it checks DNS for configured records.
- Health server binds 127.0.0.1:9999 by default.
- Upstream README says the image is ~12 MB, scratch based.
