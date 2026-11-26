# TrueCharts chart: ferdi-server

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ferdi-server (chart values fetched via raw `charts/stable/ferdi-server/values.yaml`, 2026-11-26)

## Image

- `repository`: `docker.io/getferdi/ferdi-server`
- `tag`: `1.3.2@sha256:6e620b85afaa186f883336dc2672cc4a3a7b132eda94d160886d232d20d4335f`
- `pullPolicy`: `IfNotPresent`

## Security

- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`. No `podSecurityContext`.

## Ports

- service `main` port `10206` -> targetPort `3333`.

## Persistence

- `data`: `mountPath: /app/data`, enabled.
- `recipes`: `mountPath: /app/recipes`, enabled. No `type` given in the chart snippet.

## Env (container main)

- `NODE_ENV=production`, `DATA_DIR=/app/data`
- `DB_CONNECTION=pg` (Postgres driver value as used by the chart)
- `DB_PORT=5432`, `DB_SSL=false`
- `DB_USER` and `DB_DATABASE` from `.Values.dependencies.postgresql.depconfig` (`postgresqlUsername`, `postgresqlDatabase`)
- `DB_HOST` and `DB_PASSWORD` from secret `<release>-postgresqlcreds` (keys `plainhost` and `postgresql-password`)
- `APP_URL=http://localhost:3333`
- `IS_CREATION_ENABLED`, `IS_DASHBOARD_ENABLED`, `IS_REGISTRATION_ENABLED`, `CONNECT_WITH_FRANZ`: all `true`.
- Mail/SMTP variables commented out.

## Other

- `ferdiServer.appKey`: placeholder to change.
- Init container `1-create-key-file` (type install) with `APP_KEY` from secret `secrets`/`APP_KEY`.
- Probes (liveness, readiness, startup): `path: /health`.
- `dependencies.postgresql.enabled: true`, `depconfig.postgresqlUsername: ferdi-server`, `depconfig.postgresqlDatabase: ferdi-server`.

## Gotchas and contradictions

- The chart's Postgres use is a chart choice, not upstream default (upstream defaults to SQLite). So "PostgreSQL is a hard dependency" in the draft describes the chart, not the software.
- The chart pins the dead 1.3.2 image; `DB_CONNECTION: pg` was used with that image and is not confirmed for ferdium-server 2.x.
- Chart uses `/app/data` and `/app/recipes`; the 2.x upstream uses `/data` as `DATA_DIR` by default.
