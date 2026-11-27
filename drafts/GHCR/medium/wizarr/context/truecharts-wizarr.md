# TrueCharts wizarr (charts/stable/wizarr)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wizarr/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `wizarr` v15.0.0, appVersion 2026.10.1, train stable, depends on `common` 32.8.5.
- Sources: ghcr.io/wizarrrr/wizarr, github.com/Wizarrrr/wizarr.

## Image
- `ghcr.io/wizarrrr/wizarr`, tag `v2026.10.1@sha256:08f2c6de...`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: protocol http, port **10596** -> targetPort **5690**.

## Env
| Var | Value |
| --- | --- |
| DISABLE_BUILTIN_AUTH | false |

## Probes
| Probe | Type | Path |
| --- | --- | --- |
| liveness | http | / |
| readiness | http | / |
| startup | tcp | (default port) |
(Upstream HEALTHCHECK uses /health; chart probes use /.)

## Volumes
| Name | Mount | Notes |
| --- | --- | --- |
| database | /data/database | enabled |
| varrun | /var/run | emptyDir, disabled |
| nginxrun | /run/nginx | emptyDir, enabled |

## Security
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
