# TrueCharts gridcoinwalletgui chart (reference only)

Source URLs:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gridcoinwalletgui/values.yaml (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gridcoinwalletgui (not fetched; values.yaml read instead)

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/sublivion/gridcoinwalletgui |
| tag | latest@sha256:0f7dbd680dd3304734e3fe42a4144e19a83c984ef9c60ef6c765f7d1b47eca2d |
| pullPolicy | IfNotPresent |

## Ports
- service.main: port 6901 (http, noVNC) -> targetPort 6901
- service.vncport: port 5901 tcp -> targetPort 5901 (enabled)

## Env
| Name | Source |
| --- | --- |
| VNC_PW | secret env-secrets, key VNC_PW |
| VNC_RESOLUTION | 1920x1080 |

## Persistence
| Name | mountPath |
| --- | --- |
| appdataconfigpath | /headless/.GridcoinResearch/ |
| boincdatadir | /var/lib/boinc-client/ |

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0. No podSecurityContext.

## Gotchas
- Chart uses `latest` plus digest; not a version pin.
- Chart runs as root with writable rootfs.
