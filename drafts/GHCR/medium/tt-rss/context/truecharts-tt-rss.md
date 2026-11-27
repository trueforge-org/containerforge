# TrueCharts tt-rss (charts/stable/tt-rss)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tt-rss/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `tt-rss` v23.0.0, appVersion `latest`, category rss, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts) and PostgreSQL (`dependencies.postgresql.enabled: true`).
- Sources listed: ghcr.io/tt-rss/tt-rss, ghcr.io/tt-rss/tt-rss-web-nginx, git.tt-rss.org/fox/tt-rss.

## Images (pinned by digest, tag `latest@sha256:...`)
| Key | Repository | Digest (short) |
| --- | --- | --- |
| image | ghcr.io/tt-rss/tt-rss | d53e1f4f... |
| nginxImage | ghcr.io/tt-rss/tt-rss-web-nginx | 49125bb5... |
| updaterImage | ghcr.io/tt-rss/tt-rss | d53e1f4f... (same as image) |

## Workloads
| Workload | Type | Container | Notes |
| --- | --- | --- | --- |
| main | pod (default) | main (image) | runs app (php-fpm), runAsUser 0 in securityContext, readOnlyRootFilesystem false |
| nginx | Deployment | nginx (nginxImage, primary) | web front, APP_UPSTREAM = <fullname>-app, APP_WEB_ROOT=/var/www/html/tt-rss, APP_BASE="" |
| updater | Deployment | updater (updaterImage) | args `/opt/tt-rss/updater.sh` |

## Probes
| Workload | Liveness | Readiness | Startup |
| --- | --- | --- | --- |
| main | exec `netstat -npl \| grep :9000` | exec `ls /var/www/html/tt-rss/.app_is_ready` | tcp app port |
| nginx | http `/public.php?op=healthcheck` on main port | same | tcp main port |
| updater | exec `test -f /var/www/html/tt-rss/lock/update_daemon.lock` | same | same |

## Env (main + updater)
| Var | Value in chart |
| --- | --- |
| TTRSS_SELF_URL_PATH | "" |
| ADMIN_USER_PASS | secretKeyRef env-secrets/ADMIN_USER_PASS |
| TTRSS_DB_NAME | postgresql depconfig database `tt-rss` |
| TTRSS_DB_USER | postgresql depconfig user `tt-rss` |
| TTRSS_DB_PORT | "5432" |
| TTRSS_DB_PASS | secret `<release>-postgresqlcreds` key postgresql-password |
| TTRSS_DB_HOST | secret `<release>-postgresqlcreds` key plainhost |
| nginx: APP_UPSTREAM, APP_WEB_ROOT, APP_BASE | see above |

## Ports (service)
- service.main -> targetSelector nginx, port **10104** (nginx listen, from configmap template).
- service.app -> targetSelector main, port **9000** (php-fpm).

## Volumes / persistence
| Name | Mount(s) |
| --- | --- |
| html | main, updater: /var/www/html ; nginx: /var/www/html (readOnly) |
| config | main, updater: /opt/tt-rss/config.d |
| nginx-conf | configmap `config` key `nginx.conf.template` -> nginx: /etc/nginx/templates/nginx.conf.template (subPath) |

## Config files
- configmap `config`: nginx.conf.template (worker/events/http, server listens on `{{ service.main.ports.main.port }}`, `/cache` internal aio, `/backups` internal, `/healthz` rewrite, fastcgi_pass `${APP_UPSTREAM}:9000`).
- secret `env-secrets`: ADMIN_USER_PASS "" (generated when empty).

## Upstream image facts (see tt-rss-app-dockerfile.md, tt-rss-nginx-dockerfile.md)
- Startup via `startup.sh`; app uid/gid OWNER_UID/OWNER_GID.
