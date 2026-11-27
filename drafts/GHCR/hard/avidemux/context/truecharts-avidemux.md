# TrueCharts avidemux (chart 17.1.1)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avidemux/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `avidemux` 17.1.1, appVersion **26.11.2**, category media, common 32.8.5.
- Description: free video editor for cutting, filtering and encoding.
- Chart sources: ghcr.io/jlesage/avidemux, github jlesage/docker-avidemux.

## Image
- repository: `ghcr.io/jlesage/avidemux`
- tag: `v26.11.2@sha256:c553a37997974faeb37da309fac3f0a879fdf6b0d36bd0a8fd33ba0cdd2328a9`
- pullPolicy: IfNotPresent

## Security context
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0
- main container capabilities add: NET_BIND_SERVICE, KILL

## Ports
| Name | Protocol | Port (service) | targetPort |
| --- | --- | --- | --- |
| main | http | 10272 | 5800 |
| vnc (enabled) | tcp | 10273 | 5900 |

## Env
| Env (via configmap `avidemux`) | Chart value |
| --- | --- |
| KEEP_APP_RUNNING | false -> "0" |
| DISPLAY_WIDTH | 1280 |
| DISPLAY_HEIGHT | 768 |
| SECURE_CONNECTION | false -> "0" |
| ENABLE_CJK_FONT | false -> "0" |
| VNC_PASSWORD | secretKeyRef `env-secrets`/`VNC_PASSWORD` (empty by default) |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| storage | /storage |
| varrun | disabled |

## Gotchas
- Chart runs as root; VNC password secret is empty by default.
