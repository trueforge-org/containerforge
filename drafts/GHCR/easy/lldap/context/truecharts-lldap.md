# TrueCharts lldap chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lldap/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lldap/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `lldap` v11.0.0, appVersion 0.6.3. Lightweight LDAP auth server. Category ldap. Depends on `common` 32.8.5 and a `postgresql` subchart (enabled).

## Runtime deps
- Image: `ghcr.io/lldap/lldap`, tag `v0.6.3-debian@sha256:2f208d7dc45d0b01648ab9c869fa6f65b843a8c9647e99dd929739f5a51a945b`, pullPolicy IfNotPresent.
- PostgreSQL subchart (`dependencies.postgresql.enabled: true`, user/db `lldap`).

## Entrypoint/flags
- command: `/app/lldap`, args: `run`.

## Env vars (chart values)
| Name | Value |
| --- | --- |
| LLDAP_HTTP_PORT | `{{ service.main.port }}` (17170) |
| LLDAP_LDAP_PORT | `{{ service.ldap.port }}` (3890) |
| LLDAP_HTTP_URL | `http://localhost:<http port>` |
| LLDAP_LDAP_BASE_DN | dc=example,dc=com |
| LLDAP_LDAP_USER_DN | admin |
| LLDAP_LDAP_USER_EMAIL | admin@example.com |
| LLDAP_LDAP_USER_PASS | secretKeyRef env-secrets (chart default "password"; redacted) |
| LLDAP_VERBOSE | false |
| LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET | false |
| LLDAP_SMTP_OPTIONS__SERVER | "" |
| LLDAP_SMTP_OPTIONS__PORT | 587 |
| LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION | STARTTLS |
| LLDAP_SMTP_OPTIONS__USER | "" |
| LLDAP_SMTP_OPTIONS__PASSWORD | secretKeyRef env-secrets (default "") |
| LLDAP_SMTP_OPTIONS__FROM | "LLDAP Admin <sender@gmail.com>" |
| LLDAP_SMTP_OPTIONS__REPLY_TO | "Do not reply <noreply@localhost>" |
| LLDAP_JWT_SECRET | secretKeyRef `secret`/LLDAP_JWT_SECRET |
| LLDAP_key_file | /data/private_key |
| LLDAP_database_url | secretKeyRef `{{Release.Name}}-postgresqlcreds`/url |

- `lldap.jwtSecret` value is a placeholder that "must be changed" (value not recorded).

## Ports
- service.main `main`: 17170 (HTTP UI/API).
- service.ldap `ldap`: 3890 (LDAP, enabled).

## Volumes/paths
- persistence.data: `/data` (enabled).

## User/UID
- securityContext.container: readOnlyRootFilesystem false. No runAsUser set in chart values.

## Healthcheck/probes
- Not set in values.

## Version/asset naming
- Chart 11.0.0; image tag `v0.6.3-debian` pinned by digest.

## Gotchas
- Chart sets `LLDAP_key_file` and `LLDAP_database_url` (secretKeyRef) explicitly; the DB URL comes from the postgres subchart secret.
- JWT secret and admin password defaults are placeholders and must be overridden.
