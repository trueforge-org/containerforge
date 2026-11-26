# TrueCharts chart: fireflyiii

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fireflyiii (chart values via raw `values.yaml`, fetched 2026-11-26)

## Image

- `repository`: `docker.io/fireflyiii/core`
- `tag`: `version-6.2.21@sha256:3db5043e29495ec61b3b1fe163e42629629df7b7841eac3bad7bff13dbe05fad`
- `pullPolicy`: `IfNotPresent`

## Security

- `securityContext.container`: `runAsUser: 33`, `runAsGroup: 33`, `readOnlyRootFilesystem: false`. `privileged` not set.

## Persistence

- `data` -> `/var/www/html/storage/upload`, enabled. No `type`.
- `varrun`: disabled.

## Env (verbatim keys)

- `DB_USERNAME`, `DB_DATABASE`, `DB_CONNECTION` = `pgsql`, `DB_PORT` = `5432`
- `DB_HOST` and `DB_PASSWORD` from secret `postgresqlcreds` (keys `plainhost`, `postgresql-password`)
- `REDIS_DB` = `"0"`, `REDIS_CACHE_DB` = `"1"`, `REDIS_SCHEME` = `tcp`, `REDIS_PORT` = `6379`
- `REDIS_HOST` and `REDIS_PASSWORD` from secret `valkeycreds` (keys `plainhost`, `valkey-password`)
- `CACHE_DRIVER` = `redis`, `SESSION_DRIVER` = `redis`
- `APP_URL` empty; `TRUSTED_PROXIES` = `172.16.0.0/16`
- `STATIC_CRON_TOKEN` and `APP_KEY` from secret `firefly-secrets`

## Ports and probes

- service `main` port `10082` -> targetPort `8080`.
- Liveness, readiness and startup probes: HTTP `/healthcheck`.

## Dependencies

- `valkey`: enabled.
- `postgresql`: enabled (`postgresqlUsername: firefly`, `postgresqlDatabase: firefly`).

## Cron

- CronJob schedule `0 3 * * *` (daily 03:00). Placeholders `appKey` and `cronToken` must be changed.

## Gotchas

- The chart runs Redis/Valkey as cache and session driver and PostgreSQL as DB; the upstream `.env.example` defaults are `file` drivers and mysql. Chart choice, not an upstream requirement.
- The chart pins version 6.2.21; plan targets 6.7.9.
- Probe path `/healthcheck` differs from plan's container-test `/`.
