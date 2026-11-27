# TrueCharts blender (charts/stable/blender)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blender/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `blender` v11.0.0, appVersion latest, train stable, depends on `common` 32.8.5.
- Sources: fleet.linuxserver.io, github linuxserver/docker-blender, lscr package page, www.blender.org.

## Image
- `lscr.io/linuxserver/blender`, tag `latest@sha256:1dc6e346...` (unpinned tag, digest pinned).

## Ports
- service.main.ports.main: **3000** tcp -> targetPort 3000. (Upstream Dockerfile EXPOSE 3001; see linuxserver file. Chart and image disagree.)

## Env
| Var | Value |
| --- | --- |
| KEYBOARD | "" |
| SUBFOLDER | "" |

## Volumes
| Name | Mount |
| --- | --- |
| config | /config |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
- None overridden.
