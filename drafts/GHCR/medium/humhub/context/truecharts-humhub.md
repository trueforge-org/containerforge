# TrueCharts chart: humhub (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/humhub/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
Chart `humhub` v18.0.0, appVersion 1.17.2, library `common` 32.8.5. Social network kit in PHP. Multi-container: `main` (phponly php-fpm) + `nginx` Deployment.

## Images
- main: `ghcr.io/mriedmann/humhub-phponly` tag `1.17.2@sha256:3f00ef2b0ef98b4665acdad27f7f0c40325391182193bdb783c64e26a9b94b2c`
- nginx: `ghcr.io/mriedmann/humhub-nginx` tag `1.17.2@sha256:47fb119e2e0a182546a93646efcb5cd3f480171398eb1551b31e2030ec93c578`
- pullPolicy IfNotPresent

## Install/build steps (chart side)
- Dependencies: `mariadb` (enabled, depconfig user `humhub`, db `humhub`), `valkey` (enabled).

## Ports / services
| service | port | targetPort | note |
| --- | --- | --- | --- |
| main | 8080 | 80 (nginx) | targetSelector nginx |
| backend | 9000 | 9000 (main) | ClusterIP, php-fpm FastCGI |

## Probes
- main: liveness/readiness/startup exec `/usr/local/bin/php-fpm-healthcheck`
- nginx: liveness/readiness http `/ping` port 80; startup tcp 80

## Env vars (main)
| name | value |
| --- | --- |
| HUMHUB_AUTO_INSTALL | true |
| HUMHUB_INTEGRITY_CHECK | true |
| WAIT_FOR_DB | true |
| HUMHUB_DB_USER / HUMHUB_DB_NAME | from mariadb depconfig |
| HUMHUB_DB_PASSWORD / HUMHUB_DB_HOST | secret `<release>-mariadbcreds` keys mariadb-password / plainhost |
| HUMHUB_QUEUE_CLASS | humhub\modules\queue\driver\Redis |
| HUMHUB_CACHE_CLASS | yii\redis\Cache |
| HUMHUB_CACHE_EXPIRE_TIME | 3600 |
| HUMHUB_REDIS_PORT | 6379 |
| HUMHUB_REDIS_HOSTNAME / HUMHUB_REDIS_PASSWORD | secret `<release>-valkeycreds` keys plainhost / valkey-password |
| HUMHUB_MAILER_* | system address/name, transport smtp, hostname, port 1025, user, password (secret env-secrets), encryption, allow_self_sign_certs |
| HUMHUB_PROTO | http |
| HUMHUB_HOST | localhost:8080 |
| HUMHUB_ADMIN_LOGIN / HUMHUB_ADMIN_EMAIL | admin / humhub@example.com |
| HUMHUB_ADMIN_PASSWORD | secret env-secrets |

Env (nginx): NGINX_CLIENT_MAX_BODY_SIZE 10m, NGINX_KEEPALIVE_TIMEOUT 65, NGINX_UPSTREAM `<fullname>-backend:9000`, HUMHUB_REVERSEPROXY_WHITELIST `10.0.0.0/8;172.16.0.0/16;192.168.0.0/24`.

## Volumes / paths
| persistence | mountPath |
| --- | --- |
| config | /var/www/localhost/htdocs/protected/config |
| assets | /var/www/localhost/htdocs/assets (main + nginx) |
| themes | /var/www/localhost/htdocs/themes (main + nginx) |
| modules | /var/www/localhost/htdocs/protected/modules (main + nginx) |
| uploads | /var/www/localhost/htdocs/uploads (main + nginx) |

## User/UID
- securityContext.container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false (chart runs as root, unlike ContainerForge target).

## Gotchas
- Chart appVersion 1.17.2; plan targets newer upstream.
- Admin password `test` and HUMHUB_HOST localhost:8080 are chart defaults, not container defaults.
