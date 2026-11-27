# TrueCharts chart: amule

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/amule/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/amule/values.yaml (2026-11-27)

## What it is
- Chart `amule` v15.0.0, `appVersion: 3.2.0`, category Downloaders, train stable.
- Description: aMule is an eMule-like client for the eDonkey and Kademlia networks.
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- `ghcr.io/ngosang/amule`
- tag `3.2.0-1@sha256:4b1a4246d57e7994b31c723b8c55474654e328c1b8eb0f9deb7f1843673bd515`
- pullPolicy IfNotPresent

## Env vars
| Name | Source |
| --- | --- |
| WEBUI_PWD | secretKeyRef `env-secrets` key `WEBUI_PWD` (chart placeholder `CHANGE_ME_VERY_SECURE`) |
| GUI_PWD | secretKeyRef `env-secrets` key `GUI_PWD` (chart placeholder `CHANGE_ME_VERY_SECURE`) |

- Commented-out in chart: `MOD_AUTO_RESTART_ENABLED`, `MOD_AUTO_RESTART_CRON`.
- Chart comments: aMule writes completed downloads to `/downloads/incoming`, incomplete to `/downloads/temp`; `INCOMING_DIR` and `TEMP_DIR` env vars change those paths.

## Ports
| Service | Port | Protocol | targetPort | Use |
| --- | --- | --- | --- | --- |
| main | 4711 | http | 4711 | web UI (probes on `/`) |
| remote (gui) | 4712 | tcp | 4712 | remote GUI (enabled) |
| ed2k tcp | 4662 | tcp | 4662 | ed2k (enabled) |
| ed2k udp | 4665 | udp | 4665 | ed2k global search (enabled) |
| ed2k udp2 | 4672 | udp | 4672 | ed2k UDP (enabled) |

## Probes
- liveness, readiness, startup: `type: http`, `path: /`, service main.

## Volumes / paths
| Persistence | mountPath |
| --- | --- |
| config | /home/amule/.aMule |
| downloads | /downloads |

## Security context
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Gotchas
- Two web-facing secrets are placeholders in the chart; real values must come from the user.
- Chart's probes use HTTP on 4711, so the web UI must answer `/` for readiness.
