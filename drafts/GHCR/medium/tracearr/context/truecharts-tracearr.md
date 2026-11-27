# TrueCharts chart: tracearr (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tracearr/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `tracearr` v9.0.0, library `common` 32.8.5, appVersion 3.2.1, category media.
- Streaming access manager for Plex, Jellyfin, Emby with account-sharing detection.

## Image (values.yaml)
- repository: `ghcr.io/connorgallopo/tracearr`
- tag: `3.2.1@sha256:6bcaf17c012b4fe11b898f343244af19b3c87b7847bdc652897e2c9781465f2c`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | proto |
| --- | --- | --- | --- |
| main | 3000 | 3000 | http |

## Persistence
- None set in values (chart defaults only).

## Env (workload.main containers.main)
| var | value |
| --- | --- |
| PORT | service port (3000) |
| JWT_SECRET | secret `env-secrets` key JWT_SECRET |
| COOKIE_SECRET | secret `env-secrets` key COOKIE_SECRET |
| MAXMIND_LICENSE_KEY | secret `env-secrets` key MAXMIND_LICENSE_KEY (optional) |
| CORS_ORIGIN | "*" |
| LOG_LEVEL | info |
| TRUST_PROXY | true |
| DATABASE_URL | secretKeyRef `<release>-postgresqlcreds` key `url` |
| REDIS_URL | secretKeyRef `<release>-valkeycreds` key `url` |

Secret `env-secrets` defaults: JWT_SECRET "changeme", COOKIE_SECRET "changeme", MAXMIND_LICENSE_KEY "".

## Dependencies
- postgresql enabled: username `tracearr`, database `tracearr`.
- valkey enabled.

## Security context (chart values)
- readOnlyRootFilesystem: false.
