# TrueCharts linkding (stable) - values.yaml + Chart.yaml

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkding/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart name `linkding`, chart version 15.0.0, appVersion 1.47.0, category `bookmarks`.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources listed: ghcr.io/sissbruecker/linkding, github.com/sissbruecker/linkding.

## Image
- repository `ghcr.io/sissbruecker/linkding`
- tag `1.47.0@sha256:e35cb50e0581178f245125ffaa909c565416c94c9f22ace305a7d234a4345522`
- pullPolicy IfNotPresent

## Ports
| Name | Chart service port | Env |
| --- | --- | --- |
| main | 10210 | `LD_SERVER_PORT` = `{{ .Values.service.main.ports.main.port }}` (i.e. 10210) |

## Persistence
| Name | Mount path |
| --- | --- |
| data | `/etc/linkding/data` (enabled) |

## Security context (chart values)
- readOnlyRootFilesystem: false
- runAsNonRoot: false
- runAsUser: 0, runAsGroup: 0

## Env vars (chart)
| Var | Value |
| --- | --- |
| LD_SERVER_PORT | service port (10210) |
| LD_REQUEST_TIMEOUT | 60 |
| LD_DISABLE_BACKGROUND_TASKS | false |
| LD_DISABLE_URL_VALIDATION | false |
| LD_SUPERUSER_NAME | "superuser" |
| LD_SUPERUSER_PASSWORD | secretKeyRef env-secrets/LD_SUPERUSER_PASSWORD |

Secret `env-secrets` (enabled) default data: `LD_SUPERUSER_PASSWORD: "somesecret"`.

## Gotchas
- Chart runs the container as root (runAsUser 0) and disables read-only rootfs. Upstream image itself sets no USER.
- Chart service port (10210) differs from upstream default port (9090); the chart overrides via LD_SERVER_PORT.
