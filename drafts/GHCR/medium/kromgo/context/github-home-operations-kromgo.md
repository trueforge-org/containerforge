# Upstream: home-operations/kromgo (commit 5a14ed14fff8)

Source URL(s) + date: https://raw.githubusercontent.com/home-operations/kromgo/5a14ed14fff8/{Dockerfile,README.md} (fetched 2026-11-27)

## What it is
- Go service exposing Prometheus queries as shields.io-style SVG badges and graphs (`/badges/{id}`, graph endpoints), with `/healthz`, `/readyz`.
- Config file defines endpoints (badges, graphs, defaults, CEL valueExpr expressions).

## Build (Dockerfile)
- Global ARGs: `NODE_VERSION`, `GO_VERSION` (supplied by release workflow from mise).
- Stage `assets`: `FROM node:${NODE_VERSION}-alpine`. `ARG PNPM_VERSION` (required). `npm install --global --ignore-scripts pnpm@${PNPM_VERSION}`. `pnpm install --frozen-lockfile` (package.json, pnpm-lock.yaml). Vendors marked, github-markdown-css, @mdi/svg, simple-icons.
- Stage `builder`: `FROM golang:${GO_VERSION}-alpine`. ARG VERSION=dev, REVISION=dev. `go mod download`, `COPY . .`, copies `node_modules` from assets, `go run ./cmd/genassets` (embeds assets), `CGO_ENABLED=0 go build -ldflags "-s -w -X main.Version=... -X main.Gitsha=..." -trimpath -o /out/kromgo ./cmd/kromgo`.
- Final: `FROM gcr.io/distroless/static:nonroot`. `COPY --from=builder /out/kromgo /kromgo`.

## Runtime
- `EXPOSE 8080/tcp 8081/tcp`. `ENTRYPOINT ["/kromgo"]`. No CMD, no USER beyond distroless nonroot (UID 65532), no ENV, no VOLUME.

## Config
- Reads `/config/config.yaml` by default. Override with `-config /path/to/config.yaml` flag.
- Docker example mounts `-v /path/config.yaml:/config/config.yaml`, `KROMGO_PROMETHEUS_URL`, `-p 8080:8080`.

## Env vars (README table)
| Var | Required | Default | Purpose |
| --- | --- | --- | --- |
| KROMGO_PROMETHEUS_URL | yes | none | Prometheus URL |
| KROMGO_SERVER_HOST | no | all | Bind host |
| KROMGO_SERVER_PORT | no | 8080 | Main server port |
| KROMGO_METRICS_HOST | no | all | Metrics bind host |
| KROMGO_METRICS_ENABLED | no | true | Serve /metrics; off = no listener |
| KROMGO_METRICS_PORT | no | 8081 | Metrics port (/metrics only) |
| KROMGO_SERVER_LOGGING | no | false | HTTP access log |
| KROMGO_SERVER_READ_TIMEOUT | no | - | e.g. 5s |
| KROMGO_SERVER_WRITE_TIMEOUT | no | - | e.g. 10s |
| KROMGO_QUERY_TIMEOUT | no | 30s | Per-query timeout |
| KROMGO_LOG_LEVEL | no | info | debug, info, warn, error |
| KROMGO_LOG_FORMAT | no | json | json or text |

- No `KROMGO_HEALTH_PORT` in the README (chart sets it).

## Ports
| Port | Purpose |
| --- | --- |
| 8080 | Main server: badges, graphs, /healthz, /readyz |
| 8081 | Metrics server: /metrics (optional) |

## Healthcheck
- Probes `/healthz` and `/readyz` on the main port (8080 default).

## Version/asset naming
- Release tag `0.16.4` (no `v` prefix, per plan). Image `ghcr.io/home-operations/kromgo:0.16.4` (chart).

## Gotchas
- Dockerfile build requires `NODE_VERSION`, `GO_VERSION`, `PNPM_VERSION` build args (no defaults in this file).
- Generated assets are not committed; `genassets` runs at build time.
- Chart sets `KROMGO_HEALTH_PORT`, which the README and Dockerfile do not document.
