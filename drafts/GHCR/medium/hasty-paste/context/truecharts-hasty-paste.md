# TrueCharts chart: hasty-paste

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hasty-paste/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hasty-paste/Chart.yaml (fetched 2026-11-27; the file is the chart metadata, read but not needed beyond values)

## What it is
- Chart for Hasty Paste II (paste sharing service). Self-contained SQLite, no DB dependency in chart.

## Image
- `repository: ghcr.io/enchant97/hasty-paste`
- `tag: 2.5.1@sha256:d69120f176fd330304914a13505c68d8d8df85a4ec9f9cf37613f2af769c9f8a` (no `v` prefix in chart tag)
- `pullPolicy: IfNotPresent`

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| PUBLIC_URL | `http://example.com` (placeholder) |
| AUTH_TOKEN_SECRET | secretKeyRef `env-secrets`/`AUTH_TOKEN_SECRET` (default empty) |
| SESSION_SECRET | secretKeyRef `env-secrets`/`SESSION_SECRET` (default empty) |
| BIND__PORT | `{{ .Values.service.main.ports.main.port }}` (= 10601) |

## Ports
- Service `main`: protocol http, port 10601.

## Volumes/paths
- `persistence.config`: enabled, `mountPath: /opt/hasty-paste/data`.

## User/UID
- Chart: no securityContext set in values.

## Config files
- None in chart. Secrets in `env-secrets` (AUTH_TOKEN_SECRET, SESSION_SECRET, both empty default).

## Healthcheck
- None in chart values. Upstream image has HEALTHCHECK `./hasty-paste health-check`.

## Gotchas
- Chart `BIND__PORT` follows the service port (10601). Upstream default 8080.
- `PUBLIC_URL` default is a placeholder `http://example.com`.
- Secrets empty by default: AUTH_TOKEN_SECRET and SESSION_SECRET.
