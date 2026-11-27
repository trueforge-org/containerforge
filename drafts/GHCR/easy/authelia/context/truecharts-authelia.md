# TrueCharts chart: authelia (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/authelia/values.yaml , .../Chart.yaml

## What it is
- Chart `authelia` version 35.0.0, appVersion 4.39.28, dep `common` 32.8.5
- Description: "Authelia is a Single Sign-On Multi-Factor portal for web apps"
- Sources: https://ghcr.io/authelia/authelia , https://github.com/authelia/authelia , https://github.com/authelia/chartrepo

## Image (values.yaml)
- repository `ghcr.io/authelia/authelia`
- tag `4.39.28@sha256:bd97cff4fcbf715b5ff1f9ae286afbe6033afce385302520b0368122d43a6f54`
- replicas 2 (workload.main), strategy RollingUpdate

## Service / port
- main: port 9091 (tcp)

## Config
- `authelia` values render to secret `authelia-configfile` (key `configuration.yaml`), mounted read-only at `/configuration.yaml` (subPath)
- Chart default config: access_control default_policy one_factor; session cookie domain example.com

## Env (container `main`)
| Name | Source |
| --- | --- |
| AUTHELIA_SESSION_SECRET | secret env-secrets |
| AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET | secret env-secrets |
| AUTHELIA_STORAGE_ENCRYPTION_KEY | secret env-secrets |
| X_AUTHELIA_CONFIG | {{ persistence.configfile.mountPath }} |
| AUTHELIA_SERVER_DISABLE_HEALTHCHECK | "true" |
| AUTHELIA_SERVER_ADDRESS | tcp://:9091/ |
| AUTHELIA_STORAGE_POSTGRES_ADDRESS | from dependencies.postgresql depconfig creds (plainhost:plainport) |
| AUTHELIA_STORAGE_POSTGRES_DATABASE | authelia |
| AUTHELIA_STORAGE_POSTGRES_USERNAME | authelia |
| AUTHELIA_STORAGE_POSTGRES_PASSWORD | secret `<release>-postgresqlcreds` key postgresql-password |
| AUTHELIA_SESSION_REDIS_HOST | from dependencies.valkey depconfig creds |
| AUTHELIA_SESSION_REDIS_PORT | from dependencies.valkey service port |
| AUTHELIA_SESSION_REDIS_DATABASE_INDEX | "0" |
| AUTHELIA_SESSION_REDIS_PASSWORD | secret `<release>-valkeycreds` key valkey-password |

## Probes
- liveness, readiness, startup: `type: http`, path `/api/health`

## Persistence
- `config` enabled, mountPath `/config`
- `configfile` (secret, see above)

## Dependencies
- postgresql enabled (username/database `authelia`)
- valkey enabled

## Gotchas
- Chart sets AUTHELIA_SERVER_DISABLE_HEALTHCHECK true; probes hit /api/health
- Secrets in values are placeholders ("some-secret-replace-me")
- Chart needs PostgreSQL and Valkey (DB-dependent app)
