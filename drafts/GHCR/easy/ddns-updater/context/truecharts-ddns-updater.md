# TrueCharts chart: ddns-updater

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-updater/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-updater/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `ddns-updater` version 15.0.0, appVersion 2.10.0, train stable.
- Description: light container updating DNS A and/or AAAA records periodically for multiple DNS providers.
- Chart sources: `https://ghcr.io/qdm12/ddns-updater`, https://github.com/qdm12/ddns-updater.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/qdm12/ddns-updater` |
| tag | `v2.10.0@sha256:3e2aa558946b5a293def4d73008fa4651c072b2c12932cecd02126fb23979831` |
| pullPolicy | IfNotPresent |

## Ports
| Name | Port | Protocol |
| --- | --- | --- |
| main | 10227 | http |

No targetPort set. Chart sets `LISTENING_ADDRESS` to `:{{ .Values.service.main.ports.main.port }}` (i.e. `:10227`), so the container listens on 10227, not the upstream default 8000.

## Env (workload.main.podSpec.containers.main.env)
| Name | Chart value |
| --- | --- |
| LISTENING_ADDRESS | `:10227` (templated from port) |
| CONFIG | "" |
| PERIOD | "5m" |
| IPV6_PREFIX | "/128" |
| PUBLICIP_FETCHERS | "all" |
| PUBLICIP_HTTP_PROVIDERS | "all" |
| PUBLICIPV4_HTTP_PROVIDERS | "all" |
| PUBLICIPV6_HTTP_PROVIDERS | "all" |
| PUBLICIP_DNS_PROVIDERS | "all" |
| PUBLICIP_DNS_TIMEOUT | "3s" |
| UPDATE_COOLDOWN_PERIOD | "5m" |
| HTTP_TIMEOUT | "10s" |
| BACKUP_PERIOD | "0" |
| LOG_LEVEL | "info" |
| LOG_CALLER | "hidden" |
| SHOUTRRR_ADDRESSES | "" |

## Volumes
| Persistence | mountPath |
| --- | --- |
| data (enabled) | /updater/data |

## Probes
- liveness, readiness, startup: `type: http`, `path: /`.

## Gotchas
- Chart listens on 10227; the Dockerfile EXPOSE is 8000 and the upstream default `LISTENING_ADDRESS` is `:8000`. Container must honour the env var.
- Chart does not set securityContext (no UID/GID override in values).
