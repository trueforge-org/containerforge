# TrueCharts: humhub (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/humhub/Chart.yaml , .../values.yaml (fetched 2026-11-27; values.yaml tail after persistence not read in full)

## What it is
- Chart `humhub` version 18.0.0, appVersion 1.17.2. Category Network-Web. "feature rich ... Social Network Kit written in PHP".
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart sources: ghcr.io/mriedmann/humhub-nginx, ghcr.io/mriedmann/humhub-phponly.

## Images (values.yaml)
| Role | repository | tag |
| --- | --- | --- |
| main (php-fpm) | ghcr.io/mriedmann/humhub-phponly | 1.17.2@sha256:3f00ef2b0ef98b4665acdad27f7f0c40325391182193bdb783c64e26a9b94b2c |
| nginx | ghcr.io/mriedmann/humhub-nginx | 1.17.2@sha256:47fb119e2e0a182546a93646efcb5cd3f480171398eb1551b31e2030ec93c578 |

## Service
- main: port 8080 http -> targetPort 80 (nginx).
- backend: ClusterIP port 9000 -> 9000 (main, php-fpm).

## Chart values (humhub.*)
- nginx.max_client_body_size 10m; keep_alive_timeout 65; proto http; host localhost:8080.
- admin login admin, password "test" (chart default), email humhub@example.com.
- mailer: sys_address noreply@example.com, sys_name HumHub, type smtp, hostname "", port 1025, encrypt "", allow_self_sign_certs false.

## Env (main container)
| Name | Value / source |
| --- | --- |
| HUMHUB_AUTO_INSTALL | true |
| HUMHUB_INTEGRITY_CHECK | true |
| WAIT_FOR_DB | true |
| HUMHUB_DB_USER / HUMHUB_DB_NAME | from dependencies.mariadb.depconfig |
| HUMHUB_DB_PASSWORD | secret <release>-mariadbcreds key mariadb-password |
| HUMHUB_DB_HOST | secret <release>-mariadbcreds key plainhost |
| HUMHUB_QUEUE_CLASS | humhub\modules\queue\driver\Redis |
| HUMHUB_CACHE_CLASS | yii\redis\Cache |
| HUMHUB_CACHE_EXPIRE_TIME | 3600 |
| HUMHUB_REDIS_PORT | 6379 |
| HUMHUB_REDIS_HOSTNAME / PASSWORD | secret <release>-valkeycreds (plainhost, valkey-password) |
| HUMHUB_MAILER_* | from values; HUMHUB_MAILER_PASSWORD secret env-secrets |
| HUMHUB_PROTO / HUMHUB_HOST | from values (initial install only) |
| HUMHUB_ADMIN_LOGIN / EMAIL | from values (initial install only) |
| HUMHUB_ADMIN_PASSWORD | secret env-secrets key HUMHUB_ADMIN_PASSWORD |

## nginx container (Deployment)
- Env: NGINX_CLIENT_MAX_BODY_SIZE=10m, NGINX_KEEPALIVE_TIMEOUT=65, NGINX_UPSTREAM=<fullname>-backend:9000, HUMHUB_REVERSEPROXY_WHITELIST "10.0.0.0/8;172.16.0.0/16;192.168.0.0/24".
- Probes: liveness/readiness http /ping port 80; startup tcp 80.

## Main probes
- liveness/readiness/startup exec `/usr/local/bin/php-fpm-healthcheck`.

## Persistence (paths)
| Name | mountPath |
| --- | --- |
| config | /var/www/localhost/htdocs/protected/config |
| assets | /var/www/localhost/htdocs/assets (main and nginx) |
| themes | /var/www/localhost/htdocs/themes (main and nginx) |

## Security
- runAsNonRoot false; readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Default admin password "test" and mailer password must be changed.
- Requires MariaDB and Valkey/Redis dependencies (secrets named from release).
- Chart appVersion 1.17.2 while GitHub releases HTML listed v1.19.5 as newest (observed; not a fixed claim).
