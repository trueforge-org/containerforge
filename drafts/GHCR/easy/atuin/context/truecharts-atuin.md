# TrueCharts chart: atuin (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/atuin/values.yaml , .../Chart.yaml

## What it is
- Chart `atuin` version 9.0.0, appVersion 18.25.1, description "Magical shell history."
- Sources: https://ghcr.io/atuinsh/atuin , https://github.com/atuinsh/atuin

## Image (values.yaml)
- repository `ghcr.io/atuinsh/atuin`
- tag `18.25.1@sha256:8049083e74727566e314ca5de07f4d9db6f7baf357035b3adb23cbe23bcc2926`

## Security context
- runAsUser 1000, runAsGroup 1000 (container)

## Service / port
- main: port 8888, protocol http

## Args
- `start`

## Env (container `main`)
| Name | Chart value |
| --- | --- |
| ATUIN_HOST | 0.0.0.0 |
| ATUIN_PORT | from service.main port (8888) |
| ATUIN_OPEN_REGISTRATION | from atuin.open_registration (false) |
| ATUIN_CONFIG_DIR | /config |
| ATUIN_DB_URI | secretKeyRef `<release>-postgresqlcreds` key `url` |
| ATUIN_DB_USERNAME | dependencies.postgresql.depconfig.postgresqlUsername (atuin) |
| ATUIN_DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |

## Persistence
- `config` enabled, mountPath `/config`

## Dependencies
- postgresql enabled; depconfig username `atuin`, database `atuin`
- Chart uses an external PostgreSQL dependency (DB URI and password come from its secret)

## Gotchas
- Chart runs as uid/gid 1000; upstream Dockerfile creates user `atuin` (uid not pinned in the Dockerfile)
- Chart requires postgres: this is a DB-dependent app for the test protocol
