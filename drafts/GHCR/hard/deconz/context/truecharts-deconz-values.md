# TrueCharts deconz values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/deconz/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/deconz-community/deconz-docker`
- tag: `2.33.2@sha256:3defae1287ecc1a73b68279e12579a5a5e997a83f4ff785fe4bc30f21faf8015`

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- container capabilities add: NET_BIND_SERVICE

## Ports
| Service | Port | Notes |
| --- | --- | --- |
| main | 10008 | web (DECONZ_WEB_PORT) |
| websocket | 10001 | enabled |
| vnc | 10002 | enabled (VNC, chart) |

## Env (set by chart)
| Name | Value |
| --- | --- |
| DECONZ_WEB_PORT | templated from main service port (10008) |
| DECONZ_WS_PORT | templated from websocket port (10001) |
| DECONZ_VNC_PORT | templated from vnc port (10002) |
| DECONZ_UID | templated from `securityContext.container.PUID` |
| DECONZ_GID | templated from `securityContext.pod.fsGroup` |
| DECONZ_DEVICE | "" (override device path, e.g. /dev/ttyUSB0) |
| DECONZ_UPNP | 0 |
| DECONZ_START_VERBOSE | 0 |
| DECONZ_VNC_MODE | 1 |
| DECONZ_VNC_PASSWORD | secretKeyRef `env-secrets` / `DECONZ_VNC_PASSWORD` |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /opt/deCONZ |

## Secret
- `env-secrets` with key `DECONZ_VNC_PASSWORD` (empty default)

## Gotchas
- Chart keeps VNC enabled and sets DECONZ_VNC_MODE=1. Our plan drops VNC (see plan.md).
- DECONZ_UID/GID reference `securityContext.container.PUID` and `securityContext.pod.fsGroup`; neither key is set in this values.yaml.
