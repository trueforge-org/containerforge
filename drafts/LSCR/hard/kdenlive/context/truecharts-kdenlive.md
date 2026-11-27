# TrueCharts kdenlive (charts/stable/kdenlive)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kdenlive/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `kdenlive` v11.0.1, appVersion latest, train stable, depends on `common` 32.8.5.
- Sources: fleet.linuxserver.io, github linuxserver/docker-kdenlive, lscr package page, kdenlive.org.

## Image
- `lscr.io/linuxserver/kdenlive`, tag `latest@sha256:f8f7f78d...`.

## Ports
- service.main.ports.main: **3000** tcp -> targetPort 3000. (Upstream Dockerfile EXPOSE 3001; chart and image disagree.)

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
