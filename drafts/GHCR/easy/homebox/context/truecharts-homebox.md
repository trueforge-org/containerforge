# TrueCharts homebox (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebox/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebox/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `homebox` v13.0.0, appVersion 0.27.1. "Inventory and organization system built for the Home User."
- Depends on `common`. Keywords: homebox, inventory.
- Chart sources: ghcr.io/sysadminsmedia/homebox, github.com/sysadminsmedia/homebox.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/sysadminsmedia/homebox` |
| tag | `0.27.1@sha256:9d0b64776c694f018c0ca06faf52105a33ca376024f46bb58e6ab0e2b728bb61` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Ports

| Name | Port | Protocol |
| --- | --- | --- |
| main | 10603 | http |

- Listen port passed via `HBOX_WEB_PORT` = service port.

## Env (chart-provided)

| Var | Value |
| --- | --- |
| HBOX_MODE | `production` |
| HBOX_WEB_PORT | `{{ service.main.ports.main.port }}` (10603) |
| HBOX_WEB_HOST | `0.0.0.0` |
| HBOX_AUTH_API_KEY_PEPPER | secretKeyRef `env-secrets` (chart comment: required, >= 32 bytes, must stay stable) |
| HBOX_LOG_LEVEL | `info` (trace, debug, info, warn, error, fatal, panic) |
| HBOX_LOG_FORMAT | `text` (text, json) |
| HBOX_OPTIONS_TRUST_PROXY | `{{ ingress.main.enabled }}` |
| HBOX_DATABASE_DRIVER | `postgres` (chart; sqlite3 also supported per comment) |
| HBOX_DATABASE_HOST | secret `<release>-postgresqlcreds` key `plainhost` |
| HBOX_DATABASE_PORT | `5432` |
| HBOX_DATABASE_USERNAME | `homebox` (depconfig) |
| HBOX_DATABASE_PASSWORD | secret `<release>-postgresqlcreds` key `postgresql-password` |
| HBOX_DATABASE_DATABASE | `homebox` (depconfig) |
| HBOX_DATABASE_SSL_MODE | `disable` |

- Secret `env-secrets` in chart holds a placeholder pepper value (not recorded).

## Volumes / paths

| Name | Mount |
| --- | --- |
| data | `/data` (enabled) |

## Dependencies (chart)

- postgresql: enabled; username `homebox`, database `homebox`.

## Probes

- liveness: http `/api/v1/status`.
- readiness: http `/api/v1/status` (enabled).
- startup: tcp (enabled).

## User / UID

- No securityContext in values.yaml (chart defaults apply).

## Gotchas

- Chart uses postgres by default (`HBOX_DATABASE_DRIVER: postgres`); upstream image default is sqlite3.
- Changing the pepper invalidates API keys (chart comment).
