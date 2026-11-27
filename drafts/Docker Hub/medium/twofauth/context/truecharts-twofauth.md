# truecharts: twofauth (chart 11.0.0, appVersion 9.0.3; fetched 2026-11-27)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twofauth/values.yaml , .../Chart.yaml

## Image
- repository `docker.io/2fauth/2fauth`, tag `9.0.3@sha256:fb421b40072f9b1412fa954798bc2e2acb755dd312ce6b21c1d004ce15c2a562`, pullPolicy IfNotPresent.

## Security context
- readOnlyRootFilesystem false, runAsUser 1000, runAsGroup 1000.

## Service / ports
- service.main.ports.main: protocol http, port 8000, targetPort 8000.

## Persistence
- `persistence.config`: enabled, mountPath `/2fauth`.
- `persistence.varrun`: disabled.

## Probes (workload.main, container main)
- liveness and readiness: HTTP path `/infos`.
- startup: tcp.

## Env (chart-generated, from values)
| Env | Source value |
| --- | --- |
| APP_ENV | `local` (fixed) |
| APP_KEY | secretKeyRef `twofauth-secret`/`APP_KEY` |
| APP_NAME | twofauth.app.name (default `2FAuth`) |
| SITE_OWNER | twofauth.app.site_owner (`mail@example.com`) |
| APP_URL | chartContext.appUrl |
| SESSION_LIFETIME | twofauth.app.session_lifetime (120) |
| TRUSTED_PROXIES | twofauth.app.trusted_proxies (list, joined by ,) |
| MAIL_DRIVER / MAIL_HOST / MAIL_PORT / MAIL_FROM / MAIL_USERNAME / MAIL_ENCRYPTION / MAIL_FROM_NAME / MAIL_FROM_ADDRESS | twofauth.mail.* (driver `log`, port 587, encryption STARTTLS) |
| MAIL_PASSWORD | secretKeyRef `env-secrets`/`MAIL_PASSWORD` |
| AUTHENTICATION_GUARD | twofauth.auth.guard (`web-guard` or `reverse-proxy-guard`) |
| AUTH_PROXY_HEADER_FOR_USER / _FOR_EMAIL, PROXY_LOGOUT_URL | twofauth.auth.* |
| WEBAUTHN_NAME / WEBAUTHN_ID / WEBAUTHN_ICON / WEBAUTHN_USER_VERIFICATION | twofauth.webauthn.* (user_verified `preferred`) |
| DB_CONNECTION | `pgsql` (fixed) |
| DB_DATABASE / DB_USERNAME | dependencies.postgresql.depconfig (`twofauth` / `twofauth`) |
| DB_PORT | `5432` (fixed) |
| DB_HOST / DB_PASSWORD | secretKeyRef from `<release>-postgresqlcreds` (keys `plainhost`, `postgresql-password`) |

## Dependencies
- postgresql enabled (chart dependency). App uses Postgres, not SQLite, in this chart.

## Secrets
- `appKey` must be set (placeholder `PLACEHOLDERAPPKEYCHANGEME0000000`; 32 chars or `base64:` + 32-byte key).

## Gotchas
- Chart overrides DB to pgsql, so the image's SQLite default is not used in this deployment.
- Chart exposes config at `/2fauth` (matches image's `/2fauth` data dir).
