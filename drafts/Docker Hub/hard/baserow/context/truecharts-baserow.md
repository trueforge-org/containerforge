# TrueCharts chart: baserow

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/baserow/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baserow) · fetched 2026-11-26

## Container image
- repository `docker.io/baserow/baserow`
- tag `2.4.3@sha256:304bebe22bf4c66d96d11bb746727492fa91637bd6deb807b2ef464f071c215c`
- pullPolicy `IfNotPresent`

## Ports
Service main: port 10228, protocol http (targetPort 80 per Caddy default).

## Env vars
- `DATABASE_NAME`, `DATABASE_USER` from `dependencies.postgresql.depconfig` (`baserow` / `baserow`); `DATABASE_PORT` 5432; `DATABASE_HOST` and `DATABASE_PASSWORD` from secret `<release>-postgresqlcreds` (keys `plainhost`, `postgresql-password`).
- `REDIS_HOST` and `REDIS_PASSWORD` from secret `<release>-valkeycreds` (keys `plainhost`, `valkey-password`); `REDIS_USER` `default`; `REDIS_PORT` 6379; `REDIS_PROTOCOL` `redis`.
- `BASEROW_CADDY_ADDRESSES` `:10228` (templated from service port); `BASEROW_PUBLIC_URL` `http://127.0.0.1:10228`; `BASEROW_TRIGGER_SYNC_TEMPLATES_AFTER_MIGRATION` false.
- Email: `FROM_EMAIL`, `EMAIL_SMTP`, `EMAIL_SMTP_USE_TLS`, `EMAIL_SMTP_HOST` (empty), `EMAIL_SMTP_PORT` 587, `EMAIL_SMTP_USER` (empty), `EMAIL_SMTP_PASSWORD` from secret `env-secrets`.
- `SECRET_KEY` from secret `secrets` key `SECRET_KEY`; chart `baserow.secretKey` placeholder must be changed.

## User/UID & permissions
`runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`. `privileged` not set. Capabilities added: `NET_BIND_SERVICE`, `KILL`.

## Volumes/paths
`data` persistence at `/baserow/data`.

## Dependencies
postgresql enabled (user `baserow`, database `baserow`); valkey enabled.

## Healthcheck/readiness
liveness, readiness, startup: all `tcp`.

## Contradictions with plan.md
- None. Chart pins 2.4.3, `/baserow/data`, postgres and valkey siblings match plan.md sections 1 and 2.
