# brotandgames/ciao README

Source: https://raw.githubusercontent.com/brotandgames/ciao/master/README.md (fetched 2026-11-26)

## What it is
- HTTP(S) endpoint checker; status code or TCP errors; email/webhook on change
- Web UI + REST JSON API; Prometheus `/metrics` optional; HTTP Basic auth optional
- Stores state in SQLite (no external DB/cache); TLS cert expiry check daily, warn <30 days (1.9.0+)

## Install/run
- Docker: `docker run --name ciao -p 8090:3000 brotandgames/ciao`
- Images: `brotandgames/ciao`, `ghcr.io/brotandgames/ciao` (linux/amd64, linux/arm64)
- Compose: service ciao, ports `8090:3000`, volume `/opt/ciao/data:/app/db/sqlite/`
- Git: `RAILS_ENV=production bundle install`; `rails assets:precompile`; `RAILS_ENV=production ./start.sh` (port 3000)
- Helm chart oci://ghcr.io/brotandgames/charts/ciao (2.2.0); k8s example: container 3000, service 80
- Build deps (Git install): Ruby/Rails via Bundler; Docker needs nothing

## Env vars
| Var | Default / note |
| --- | --- |
| SECRET_KEY_BASE | auto-generated if omitted |
| TIME_ZONE | UTC |
| CIAO_LOG_LEVEL | WARN (DEBUG/INFO/WARN/ERROR/FATAL) |
| CIAO_BASE_URL | used for webhook placeholder link |
| BASIC_AUTH_USERNAME / BASIC_AUTH_PASSWORD | UI auth |
| PROMETHEUS_ENABLED, PROMETHEUS_BASIC_AUTH_USERNAME, PROMETHEUS_BASIC_AUTH_PASSWORD | metrics |
| SMTP_ADDRESS, SMTP_PORT, SMTP_DOMAIN, SMTP_AUTHENTICATION, SMTP_ENABLE_STARTTLS_AUTO, SMTP_USERNAME, SMTP_PASSWORD, SMTP_EMAIL_FROM, SMTP_EMAIL_TO, SMTP_SSL | email |

## Ports
- 3000 (container)

## Volumes
- /app/db/sqlite (holds `production.sqlite3`)
- Backup: `docker cp ciao:/app/db/sqlite/production.sqlite3 ...`

## Gotchas
- Auth and TLS strongly advised for public exposure
- Upgrade: back up DB, run new version, restore
- REST API: GET/POST /checks.json, GET/PATCH/PUT/DELETE /checks/<id>.json

## License
- MIT
