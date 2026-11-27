# TrueCharts chart: shlink

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink/values.yaml (fetched 2026-11-27)

## What it is
- Chart v25.0.0, appVersion 5.1.9. Category utilities.
- "A PHP-based self-hosted URL shortener that can be used to serve shortened URLs under your own custom domain."
- Sources: ghcr.io/shlinkio/shlink, github shlinkio/shlink.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts); plus chart subdeps postgresql (enabled, user/db `shlink`) and valkey (enabled).

## Image (values.yaml)
- `ghcr.io/shlinkio/shlink`, tag `5.1.9@sha256:248d38c8d7fdba90d9e0c3c7ea9e73ef73ec9f54f7f46faf8f369153cc889aab`, pullPolicy IfNotPresent

## Ports
| name | port |
| --- | --- |
| main | 10153 (PORT env) |

## Env (container main, set by chart)
| key | value |
| --- | --- |
| DEFAULT_DOMAIN | "" |
| GEOLITE_LICENSE_KEY | secretKeyRef env-secrets/GEOLITE_LICENSE_KEY |
| ANONYMIZE_REMOTE_ADDR | true |
| ENABLE_PERIODIC_VISIT_LOCATE | true |
| IS_HTTPS_ENABLED | true |
| PORT | 10153 |
| DB_DRIVER | postgres |
| DB_USER | shlink |
| DB_NAME | shlink |
| DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds`/postgresql-password |
| DB_HOST | secretKeyRef `<release>-postgresqlcreds`/plainhost |
| REDIS_SERVERS | secretKeyRef `<release>-valkeycreds`/url |

Secret `env-secrets`: GEOLITE_LICENSE_KEY default "".

## Probes
- liveness, readiness, startup: HTTP path `/rest/health`

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Upstream image (shlink v5.1.9 Dockerfile)
Source URL: https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/Dockerfile (fetched 2026-11-27)
- Base `php:8.5-alpine3.24` (stage `base`). ARG SHLINK_VERSION=latest, SHLINK_RUNTIME=rr. ENV USER_ID=1001, LC_ALL=C, WORKDIR /etc/shlink.
- PHP exts: pdo_mysql pdo_pgsql intl calendar sockets bcmath zip pdo_sqlite; runtime apk: sqlite-libs postgresql icu libzip libpng.
- Optional sqlsrv driver for x86_64 only (msodbcsql 18.5.1.1, pdo_sqlsrv 5.13.0 from Microsoft download).
- Builder: composer:2 `install --no-dev --prefer-dist --optimize-autoloader`, rm docker/ and composer.*, sed SHLINK_VERSION into AppOptions.php.
- Final: copies /etc/shlink; symlink /usr/local/bin/shlink -> /etc/shlink/bin/cli; if SHLINK_RUNTIME=rr downloads RoadRunner via `vendor/bin/rr get` into bin/.
- EXPOSE 8080. COPY docker/docker-entrypoint.sh; COPY docker/config/php.ini into PHP_INI_DIR/conf.d/.
- `USER ${USER_ID}` (1001). ENTRYPOINT `["/bin/sh", "./docker-entrypoint.sh"]`.
- LABEL maintainer Alejandro Celaya (upstream author; do not reuse as contact).

## Entrypoint (upstream docker/docker-entrypoint.sh, v5.1.9)
- `mkdir -p data/cache data/locks data/log data/proxies data/temp-geolite`
- Reads env via `bin/cli env-var:read`: GEOLITE_LICENSE_KEY, SKIP_INITIAL_GEOLITE_DOWNLOAD, INITIAL_API_KEY
- flags: `--no-interaction --clear-db-cache`; adds `--skip-download-geolite` if no license key or SKIP_INITIAL_GEOLITE_DOWNLOAD=true; adds `--initial-api-key=` if INITIAL_API_KEY set
- Runs `php vendor/bin/shlink-installer init ${flags}`
- If SHLINK_RUNTIME=rr: `exec ./bin/rr serve -c config/roadrunner/.rr.yml`

## RoadRunner config (upstream config/roadrunner/.rr.yml)
- rpc listen tcp://127.0.0.1:6001
- http address `${ADDRESS:-0.0.0.0}:${PORT:-8080}`; static dir ../../public (forbid .php, .htaccess); pool num_workers `${WEB_WORKER_NUM:-0}`, max_jobs 250
- jobs: timeout 300; pool num_workers `${TASK_WORKER_NUM:-0}`; pipeline `shlink` (memory driver)
- logs encoding `${LOGS_FORMAT:-console}`, mode production

## Ports
- Image EXPOSE 8080; chart uses PORT=10153 (RoadRunner honours PORT env).

## Volumes/paths
- /etc/shlink/data (cache, locks, log, proxies, temp-geolite). Chart does not declare persistence in values.yaml.

## User/UID
- USER 1001 (USER_ID). Chart runs as root (runAsUser 0).

## Version/asset naming
- Git tags `vX.Y.Z`. Chart pins 5.1.9.
- Latest release tag (GitHub redirect): v5.1.9. api releases/latest 403 (rate limit).

## License
- MIT (LICENSE raw v5.1.9).

## Gotchas
- Entrypoint runs installer init on every start (`--clear-db-cache`), so DB must be reachable at startup.
- Upstream image runs as UID 1001; chart overrides to root.
- Upstream Dockerfile at v5.1.9 (raw); plan's blob URL points at v5.1.8 (see README).
