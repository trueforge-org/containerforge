# community-edition compose.yml @ v3.2.2 (follow-up)

Source URL: https://raw.githubusercontent.com/plausible/community-edition/v3.2.2/compose.yml (fetched)
Also: https://raw.githubusercontent.com/plausible/community-edition/v3.2.2/README.md (fetched)

## Services
| Service | Image | Ports | Volumes | Notes |
| --- | --- | --- | --- | --- |
| plausible_db | postgres:16-alpine | none | db-data -> /var/lib/postgresql/data | POSTGRES_PASSWORD=postgres; healthcheck pg_isready -U postgres (start 1m); restart always |
| plausible_events_db | clickhouse/clickhouse-server:24.12-alpine | none | event-data -> /var/lib/clickhouse; event-logs -> /var/log/clickhouse-server; ./clickhouse/{logs,ipv4-only,low-resources}.xml -> /etc/clickhouse-server/config.d/*; ./clickhouse/default-profile-low-resources-overrides.xml -> /etc/clickhouse-server/users.d/ (ro) | CLICKHOUSE_SKIP_USER_SETUP=1; nofile 262144; healthcheck wget http://127.0.0.1:8123/ping |
| plausible | ghcr.io/plausible/community-edition:v3.2.2 | none (80/443 via override) | plausible-data -> /var/lib/plausible | nofile 65535; TMPDIR=/var/lib/plausible/tmp; BASE_URL, SECRET_KEY_BASE from .env |

- plausible command: `sh -c "/entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh run"`
- plausible depends_on both DBs (service_healthy); no healthcheck; no user set (image default)
- Pass-through env (no defaults in compose): TOTP_VAULT_KEY, DISABLE_REGISTRATION, ENABLE_EMAIL_VERIFICATION, HTTP_PORT, HTTPS_PORT, DATABASE_URL, CLICKHOUSE_DATABASE_URL, GOOGLE_CLIENT_ID/SECRET, IP_GEOLOCATION_DB, GEONAMES_SOURCE_FILE, MAXMIND_LICENSE_KEY, MAXMIND_EDITION, MAILER_ADAPTER, MAILER_EMAIL, MAILER_NAME, SMTP_HOST_ADDR, SMTP_HOST_PORT, SMTP_USER_NAME, SMTP_USER_PWD, SMTP_HOST_SSL_ENABLED, POSTMARK_API_KEY, MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_BASE_URI, MANDRILL_API_KEY, SENDGRID_API_KEY
- Named volumes: db-data, event-data, event-logs, plausible-data

## README (v3.2.2) notes
- Repo README says images point to v2.1.1 while tag is v3.2.2 (inconsistency on page).
- Postgres/ClickHouse versions beyond compose: not stated.
