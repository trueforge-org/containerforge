# TrueCharts onlinecheckyourserver (chart 11.0.0, appVersion latest)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/onlinecheckyourserver/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Checks whether a domain or IP responds to ping; alerts via Pushover when it goes offline.
- Chart sources: ghcr.io/ich777/online-check-pushover, github.com/trueforge-org/truecharts (chart tree).
- Category Tools-Utilities, train stable, not deprecated.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/ich777/online-check-pushover |
| Tag | latest (digest pinned) |
| Pull policy | IfNotPresent |

## Ports / probes
- Service main: disabled. No container ports defined.
- liveness, readiness, startup probes: all disabled.

## Env vars
| Var | Chart value |
| --- | --- |
| HOST | google.com |
| PING_INTERVAL | "300" |
| PING_RETRY | "3600" |
| PING_TIMEOUT | "10" |
| PUSHOVER_APP_TOKEN | secretKeyRef env-secrets / PUSHOVER_APP_TOKEN |
| PUSHOVER_USER_TOKEN | secretKeyRef env-secrets / PUSHOVER_USER_TOKEN |
| PUSHOVER_MESSAGE | "google.com is offline!" |
| PUSHOVER_PRIORITY | "0" |
| PUSHOVER_TITLE | "Online Check" |

## Secret
- env-secrets (enabled): keys PUSHOVER_APP_TOKEN and PUSHOVER_USER_TOKEN, both empty strings in chart.

## Persistence / paths
- persistence: {} (none).

## securityContext / args
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- No args/command.

## Gotchas
- Pushover token values are empty by default and must be supplied via the secret.
- Image uses UID 99 / GID 100 as env, no USER instruction (see upstream-onlinecheck-pushover.md).
