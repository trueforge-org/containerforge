# TrueCharts chart friendica (values)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/friendica (chart directory, referenced by draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/friendica/values.yaml (2026-11-26, WebFetch summary)

Container image: `friendica:2026.05`, digest pinned (starts `836c2f7c...`), pullPolicy IfNotPresent.

Security context: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

Persistence: `varrun` (no mount path given), `config` at `/config`, `data` at `/data`.

Service: main port 10058 -> target 80. Probes: liveness, readiness and startup all `/ping`.

Env values: MYSQL_USER and MYSQL_DATABASE from mariadb depconfig (`friendica`); MYSQL_PORT 3306; MYSQL_HOST from secret `<release>-mariadbcreds` key `plainhost`; MYSQL_PASSWORD from the same secret key `mariadb-password`. REDIS_PORT 6379; REDIS_DB 1; REDIS_HOST from `<release>-valkeycreds` key `plainhost`; REDIS_PW from key `valkey-password`. FRIENDICA_TZ from TZ; FRIENDICA_DATA_DIR `/data`; FRIENDICA_CONFIG_DIR `/config`; FRIENDICA_ADMIN_MAIL `my@domain.com` (placeholder); FRIENDICA_URL `http://localhost` + port; FRIENDICA_UPGRADE `false`; FRIENDICA_SITENAME empty; PHP_MEMORY_LIMIT 512M; PHP_UPLOAD_LIMIT 512M.

Dependencies: valkey enabled; mariadb enabled (user and db `friendica`).

Gotchas:
- TrueCharts sets `FRIENDICA_CONFIG_DIR=/config` and `FRIENDICA_DATA_DIR=/data`. The upstream image does NOT document FRIENDICA_CONFIG_DIR (only FRIENDICA_DATA_DIR), so do not assume it works in the ContainerForge image without checking.
- Chart runs root with writable rootfs, matching the draft.
- Chart's FRIENDICA_ADMIN_MAIL is a placeholder value.

Failed to fetch: none.
