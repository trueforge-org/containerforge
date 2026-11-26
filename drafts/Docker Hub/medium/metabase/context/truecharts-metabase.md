# TrueCharts: metabase chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/metabase (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metabase/values.yaml)
**Fetched:** 2026-11-26

## Image
- `docker.io/metabase/metabase:v0.65.7`, digest begins `f8dbde1aa67b…`, IfNotPresent. (The draft says v0.65.6; the chart is one patch ahead.)

## Service
- Service `main`, protocol http, port **13030** (no separate target port). `MB_JETTY_PORT` is templated from this port.

## Environment
- `MB_JETTY_PORT`: templated from the service port (13030).
- `JAVA_TIMEZONE`: templated from `.Values.TZ`.
- `MB_DB_TYPE`: `postgres`.
- `MB_DB_USER`: from `dependencies.postgresql.depconfig.postgresqlUsername`.
- `MB_DB_DBNAME`: from `dependencies.postgresql.depconfig.postgresqlDatabase`.
- `MB_DB_PORT`: `5432`.
- `MB_DB_HOST`: from a secretKeyRef (release name + `postgresqlcreds`, key `plainhost`).
- `MB_DB_PASS`: from a secretKeyRef (same secret, key `postgresql-password`).
- No `JAVA_OPTS`.

## Persistence
- One volume `plugins`: enabled, mounted at `/plugins`. No size, readOnly or type given.

## Dependencies
- PostgreSQL dependency **enabled**: `depconfig.postgresqlUsername: metabase`, `postgresqlDatabase: metabase`.
- Note: the chart effectively requires PostgreSQL; plan.md treats postgres as optional (H2 default). The chart's configuration is postgres-only.

## Security context and probes
- Not specified (no runAsUser, runAsGroup, readOnlyRootFilesystem). No probes defined.

## Other
- Schema reference `./values.schema.json`.
