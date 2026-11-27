# TrueCharts chart: rstudio

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rstudio/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rstudio/values.yaml (fetched 2026-11-27)

## What it is
- Chart `rstudio` v12.0.0, appVersion 4.6.2. Category Productivity.
- Description: IDE for R.
- Sources listed: ghcr.io/rocker-org/rstudio, github rocker-org/rocker-versioned2.

## Chart.yaml deps
- common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- repository: `ghcr.io/rocker-org/rstudio`
- tag: `4.6.2@sha256:ab667f419a10edc60f95da38149644d6f9eea266216b51dcce1d4df9e36dfcd6`
- pullPolicy: IfNotPresent

## Ports
| name | port | protocol | targetPort |
| --- | --- | --- | --- |
| main | 8787 | http | 8787 |

## Persistence
| name | mountPath |
| --- | --- |
| config | /home/rstudio/.config/rstudio |
| workspace | /home/rstudio/workspace |

## Env (container main)
| key | value |
| --- | --- |
| DISABLE_AUTH | "false" |
| GROUPID | `{{ .Values.securityContext.pod.fsGroup }}` |
| PASSWORD | secretKeyRef env-secrets/PASSWORD |
| ROOT | "FALSE" |
| USER | rstudio |
| USERID | 568 |

Secret `env-secrets` PASSWORD default: `rstudio` (chart default only).

## Security context (chart)
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart default, not rootless)

## Gotchas
- Chart uses rocker image with USER/USERID 568 env; RStudio default user is `rstudio`.
- Chart's default config persists `/home/rstudio/.config/rstudio` and `/home/rstudio/workspace`.
