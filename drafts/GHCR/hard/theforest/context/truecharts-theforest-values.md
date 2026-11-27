# TrueCharts theforest values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/theforest/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/ich777/steamcmd`, tag `theforest@sha256:afb14d903e73ea3a1a610d848b54b0c459c529c1168839cda73bf5fe6c4df56e`, pullPolicy IfNotPresent

## Security
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Ports
| service | port | proto | target | enabled |
| --- | --- | --- | --- | --- |
| gameport | 27015 | udp | 27015 | yes |
| main | 8766 | udp | 8766 | yes (service default) |
| steamqueryport | 27016 | udp | 27016 | yes |

## Env (container main)
| env | value |
| --- | --- |
| GAME_ID | "556450" |
| GAME_PARAMS | "" |
| USERNAME | "" |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |

Probes: liveness, readiness, startup disabled.

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Secret
- env-secrets: PASSWRD "" (empty default)
