# TrueCharts twtxt (charts/stable/twtxt)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twtxt/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `twtxt` v16.0.0, appVersion 0.1.1, train stable, depends on `common` 32.8.5.
- Sources: ghcr.io/nicholaswilde/twtxt, github.com/nicholaswilde/docker-twtxt, github.com/prologic/twtxt.

## Image
- `ghcr.io/nicholaswilde/twtxt`, tag `version-0.1.1@sha256:58736a73...`.

## Ports
- service.main.ports.main: port **10078** -> targetPort **8000**.

## Env
| Var | Value |
| --- | --- |
| OPEN_PROFILES | "true" |
| OPEN_REGISTRATIONS | "true" |
| COOKIE_SECRET | secretKeyRef env-secrets/COOKIE_SECRET (chart default value `supersecretchangeme`) |

## Volumes
| Name | Mount |
| --- | --- |
| config | /config |
| data | /data |
| varrun | enabled, no explicit mountPath |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0 (root in chart).

## Probes
- None set in chart values.
