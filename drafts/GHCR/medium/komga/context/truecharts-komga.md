# TrueCharts chart: komga

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/komga/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "A comics/mangas server to serve/stream pages via API". Chart version 19.0.1, `appVersion: 1.30.2`. Keywords: komga, comics, mangas, server.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources: ghcr.io/gotson/komga, github.com/gotson/komga, komga.org.

## Image
- Repository `ghcr.io/gotson/komga`
- Tag `1.30.2@sha256:e4198a0d529d2be70bee5012484538154897c2d3071043b133bdaeacb806444e`, pullPolicy IfNotPresent.

## Ports
| Name | Port |
| --- | --- |
| main | 10085 (SERVER_PORT set to this value) |

## Env vars (chart)
| Name | Value |
| --- | --- |
| SERVER_PORT | `{{ .Values.service.main.ports.main.port }}` (10085) |

## Probes
- liveness, readiness: HTTP `/actuator/health` on main port.
- startup: TCP on main port.

## Persistence
| Name | Mount |
| --- | --- |
| config | `/config` |
| data | `/data` |

## Security
- No securityContext override (chart defaults).

## Gotchas
- Chart sets `SERVER_PORT` (Spring Boot property via env), which the plan should compare against the 25600 upstream EXPOSE.
- Chart pins 1.30.2; upstream Dockerfile fetched is 1.30.1 (see GitHub file).
