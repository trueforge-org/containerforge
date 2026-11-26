# TrueCharts chart: anonaddy

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anonaddy/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anonaddy) · fetched 2026-11-26

## Container image
- repository `docker.io/anonaddy/anonaddy`
- tag `1.7.4@sha256:3901fd82...97e2ad`
- pullPolicy `IfNotPresent`; strategy `Recreate`

## Ports
- main service: port 10110, targetPort 8000.
- smtp service: enabled, port 25, targetPort 25.

## Env vars (main container)
- `ANONADDY_DOMAIN`: `chart-example.local`
- `APP_URL`: `http://localhost:10110`
- `MAIL_FROM_NAME`: `Example`, `MAIL_FROM_ADDRESS`: `mailer@example.com`
- `MAIL_DRIVER`: `smtp`, `MAIL_HOST`: `mail.example.com`, `MAIL_PORT`: 25, `MAIL_ENCRYPTION`: `tls`, `MAIL_EHLO_DOMAIN`: `mail.example.com`, `MAIL_VERIFY_PEER`: false
- `DB_DATABASE`, `DB_USERNAME`: from `dependencies.mariadb.depconfig`
- `DB_HOST`, `DB_PASSWORD`: secretKeyRef from `<release>-mariadbcreds`
- `REDIS_HOST`, `REDIS_PASSWORD`: secretKeyRef from `<release>-valkeycreds`
- `APP_KEY`, `ANONADDY_SECRET`: secretKeyRef from `anonaddy-secrets`

Chart values `appKey` and `secretKey` are placeholders that must be changed.

## User/UID & permissions
`runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`. `privileged` not set.

## Volumes/paths
Persistence `config` mounted at `/config` (the upstream image uses `/data`; chart differs).

## Healthcheck/readiness endpoints
liveness, readiness, startup: all `tcp`.

## Dependencies
valkey enabled; mariadb enabled (user and database `anonaddy`).

## Gotchas
- Chart uses SMTP on 25 as a service, so the image expects Postfix inside the container.
- Chart `/config` mount differs from upstream `/data`; plan.md section 4 uses `/config`.

## Contradictions with plan.md
- None on version. The chart pins `1.7.4` and the Hub `latest` digest matches (see Docker Hub summary).
