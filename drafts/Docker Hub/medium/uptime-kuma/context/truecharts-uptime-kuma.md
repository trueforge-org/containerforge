# truecharts: uptime-kuma (chart 16.0.0, appVersion 1.23.17)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/uptime-kuma/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Image
- repository `docker.io/louislam/uptime-kuma`, tag `1.23.17-debian@sha256:3d632903e6af34139a37f18055c4f1bfd9b7205ae1138f1e5e8940ddc1d176f9`, pullPolicy IfNotPresent.

## Security
- `security.PUID: 0`.
- securityContext.container: runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Service / ports
| Service | Port |
| --- | --- |
| main | 3001 (no targetPort set in values) |

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| config | true | `/app/data` |

## Env (chart-set)
| Env | Value |
| --- | --- |
| UPTIME_KUMA_PORT | `{{ .Values.service.main.ports.main.port }}` (3001) |

## Metrics
- `metrics.main` enabled, type servicemonitor, endpoint port `main`, path `/metrics`, prometheusRule disabled.

## Gotchas
- Chart runs as root (UID/GID 0). Data path `/app/data` matches the 1.23.17 Dockerfile VOLUME.
- Chart exposes a `/metrics` ServiceMonitor on the main port.
