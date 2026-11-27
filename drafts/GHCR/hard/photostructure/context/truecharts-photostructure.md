# TrueCharts chart: photostructure

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photostructure/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `photostructure` v14.0.0, appVersion 2026.9.4, train stable, category MediaApp-Photos.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion >=1.33.0-0; max helm 4.1, max k8s 1.35.0.

## Image
- repository: `ghcr.io/photostructure/server`
- tag: `2026.9.4-beta@sha256:2fb77ed2...c5cd6` (pinned digest, pullPolicy IfNotPresent)

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 1787 | http |

## Env (chart-set)
| var | value |
| --- | --- |
| PS_HTTP_PORT | `{{ .Values.service.main.ports.main.port }}` (1787) |
| PS_LOG_LEVEL | `error` |

## Persistence (chart mounts)
| name | mountPath |
| --- | --- |
| config | /ps/config |
| library | /ps/library |
| logs | /ps/logs |
| tempscratchdisk | /ps/tmp |

## Security context (chart)
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0 (chart runs as root).

## Gotchas
- Chart pins a `-beta` digest tag while appVersion is 2026.9.4.
- No probes or PUID/PGID set in values.
