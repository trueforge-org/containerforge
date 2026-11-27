# aceberg/WatchYourLAN: Dockerfile, README, LICENSE, latest release

Source URL(s) + date: https://raw.githubusercontent.com/aceberg/WatchYourLAN/ca9f644bccba41cdb3db952b828137fa53c2f640/Dockerfile, .../ca9f644.../README.md, https://raw.githubusercontent.com/aceberg/WatchYourLAN/main/LICENSE, https://github.com/aceberg/WatchYourLAN/releases/latest (302; api 403) (fetched 2026-11-27)

## Build (multi-stage)
- Stage builder: `--platform=$BUILDPLATFORM golang:alpine`, `tonistiigi/xx` cross helpers; `go mod download` in `backend/`; `CGO_ENABLED=0 xx-go build -ldflags='-w -s' -o /WatchYourLAN ./cmd/WatchYourLAN`.
- Final: `alpine` (no tag pinned); `apk add --no-cache arp-scan tzdata`; `mkdir /data`; copies `/WatchYourLAN` to `/app/`.
- `WORKDIR /app`; `ENTRYPOINT ["./WatchYourLAN"]`.
- No EXPOSE, no USER, no HEALTHCHECK, no VOLUME in Dockerfile.

## Runtime deps
- arp-scan (ARP scanning), tzdata. Needs host network and NET_RAW for scanning (README).

## Env vars (README table)
| Var | Default | Note |
| --- | --- | --- |
| TZ | (none) | timezone |
| HOST | 0.0.0.0 | listen address |
| PORT | 8840 | web GUI |
| THEME | sand | bootswatch theme |
| IFACES | (none) | interfaces to scan, space-separated |
| TIMEOUT | 120 | seconds between scans |
| USE_DB | sqlite | `sqlite` or `postgres` |
| PG_CONNECT | (none) | `postgres://user:pass@host:5432/db?sslmode=disable` |
| INFLUX_ENABLE | false | InfluxDB2 export |
| INFLUX_SKIP_TLS | false | |
| INFLUX_ADDR / INFLUX_BUCKET / INFLUX_ORG / INFLUX_TOKEN | (none) | InfluxDB2 |
| PROMETHEUS_ENABLE | false | `/metrics` endpoint |

- Config dir flag `-d` default `/data/WatchYourLAN`.

## Ports
- 8840 (web GUI default).

## Volumes/paths
- `/data` (Dockerfile mkdir); README mounts `$DOCKERDATAPATH/wyl:/data/WatchYourLAN`.

## Network
- README: `--network="host"` required ("WYL needs host network mode"). No auth built in.

## Gotchas
- Upstream expects host networking; chart sets `hostNetwork: true`.
- Dockerfile has no USER; runs as root.

## Version/license
- Latest release: `2.1.4` (releases/latest redirect to tag 2.1.4).
- License: MIT, Copyright (c) 2022 aceberg.

## Failures
- api.github.com releases/latest: 403 rate limit; HTML fallback used.
