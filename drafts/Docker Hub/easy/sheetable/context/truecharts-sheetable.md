# TrueCharts sheetable chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sheetable/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `sheetable`. Uses PostgreSQL as a chart dependency.

## Image used by chart
`docker.io/vallezw/sheetable` tag `v0.8.1@sha256:87db05053f61e89ead0ac2a97e1ec28335e6aec8bac1f01d352229fea880a207`, pullPolicy IfNotPresent.

## Env vars set by chart
- `CONFIG_PATH`: `/app/config/`
- `DB_DRIVER`: `postgres`
- `DB_HOST`: from secret `<release>-postgresqlcreds` key `plainhost`
- `DB_NAME`: `sheetable` (dependencies.postgresql.depconfig.postgresqlDatabase)
- `DB_PASSWORD`: from the same secret, key `postgresql-password`
- `DB_PORT`: `5432`
- `DB_USER`: `sheetable` (postgresqlUsername)
- `PORT`: from service port (10284)
- `API_SECRET`: from secret `sheetable-secrets`
- `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `secretEnv`: placeholders `email@domain.com` and `changeme`
- `sheetable.apiSecret`: placeholder `PLACEHOLDERAPISECRET` (must be changed)

## Persistence
`config`: enabled, mountPath `/app/config`.

## Service
main port 10284, protocol http.

## Dependencies
`postgresql` enabled, username `sheetable`, database `sheetable`.

## Security / probes
No securityContext or probes section in values.yaml.

## Contradictions with plan.md
- The chart runs with `DB_DRIVER=postgres` and a PostgreSQL dependency. plan.md section 10 says Postgres is optional (SQLite supported), which is consistent with the upstream code.
- The chart service port is 10284; plan.md sets PORT=8080. Not a plan error, a chart choice.
- The chart mounts `/app/config`; plan.md changes the path to `/config`. Noted in plan.md section 9.
