# TrueCharts inkscape-desktop-g3 chart (reference only)

Source URLs:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/inkscape-desktop-g3/values.yaml (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/inkscape-desktop-g3 (not fetched; values.yaml read instead)

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/accetto/ubuntu-vnc-xfce-inkscape-g3 |
| tag | latest@sha256:55697f8bb62284c028f2d7ce4cc1cee3c6f5afbfb584bcbfc35faffa29d8d392 |
| pullPolicy | IfNotPresent |

## Ports
| Name | Port | Target |
| --- | --- | --- |
| main | 6901 http | 6901 (noVNC) |
| webuivnc | 5901 tcp | 5901 (VNC, enabled) |

## Env
| Name | Value |
| --- | --- |
| VNC_PW | secret env-secrets, key VNC_PW |
| VNC_RESOLUTION | 1360x768 |

## Persistence
- internalshare: mountPath `/UNRAID_SHARE`

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0. No podSecurityContext.

## Gotchas
- Chart runs as root with writable rootfs. Upstream image runs as UID 1001.
- Chart pins `latest` plus digest.
