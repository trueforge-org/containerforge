# TrueCharts chart: paperless-ngx (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 19.2.0, appVersion 3.5.1, library dep `common` 32.8.5
- "Paperless-ngx is an application by Daniel Quinn and contributors that indexes your scanned documents."
- Category productivity, train stable

## Images (values.yaml)
| Role | Repository | Tag |
| --- | --- | --- |
| main | ghcr.io/paperless-ngx/paperless-ngx | 3.5.1@sha256:8508853b8a0f8394074260957d0be186c8c64f346973b24a7583de4580f306b9 |
| gotenbergImage | docker.io/gotenberg/gotenberg | 9.10@sha256:2ce6fcd3f5019c82b0376065b9103d6d4938d34c1c06a39a8263a9fcf47a6f5b |
| tikaImage | docker.io/apache/tika | 3.4.0.0@sha256:9f3e5bb9da4229a971a4839416b3204499f20668ee834fa741a6a7504bbea7bf |

## Ports
| Service | Port | targetPort | Notes |
| --- | --- | --- | --- |
| main | 10140 | 8000 | web UI |
| gotenberg | 3000 | 3000 | enabled = tika.enabled (false) |
| tika | 9998 | 9998 | enabled = tika.enabled (false) |

## Persistence
| Name | mountPath |
| --- | --- |
| data | /data |
| consume | /consume |
| media | /media |
| varrun | disabled |

## Dependencies
- valkey enabled; postgresql enabled (depconfig user/db: paperless-ng / paperless-ng)
- tika.enabled: false (gotenberg + tika deployments off by default)

## Env (main container)
| Env | Value |
| --- | --- |
| PAPERLESS_PORT | {{ targetPort }} (8000) |
| PAPERLESS_DATA_DIR | /data/ |
| PAPERLESS_CONSUMPTION_DIR | /consume/ |
| PAPERLESS_MEDIA_ROOT | /media/ |
| PAPERLESS_URL | "" |
| USERMAP_UID | {{ securityContext.container.PUID }} |
| USERMAP_GID | {{ securityContext.pod.fsGroup }} |
| PAPERLESS_TIME_ZONE | {{ TZ }} |
| PAPERLESS_DBENGINE | postgresql |
| PAPERLESS_DBNAME | paperless-ng |
| PAPERLESS_DBUSER | paperless-ng |
| PAPERLESS_DBPORT | 5432 |
| PAPERLESS_DBHOST | secret postgresqlcreds / plainhost |
| PAPERLESS_DBPASS | secret postgresqlcreds / postgresql-password |
| PAPERLESS_TIKA_ENABLED | 1 if tika.enabled else 0 |
| PAPERLESS_TIKA_GOTENBERG_ENDPOINT | http://<fullname>-gotenberg:3000 |
| PAPERLESS_TIKA_ENDPOINT | http://<fullname>-tika:9998 |
| PAPERLESS_WEBSERVER_WORKERS | 2 |
| PAPERLESS_SECRET_KEY | secret secrets / PAPERLESS_SECRET_KEY |
| PAPERLESS_REDIS | secret valkeycreds / url |
| PAPERLESS_ADMIN_USER | admin |
| PAPERLESS_ADMIN_PASSWORD | secret env-secrets / PAPERLESS_ADMIN_PASSWORD (chart default "admin") |
| PAPERLESS_ADMIN_MAIL | admin@admin.com |
| PAPERLESS_OCR_LANGUAGE | eng |
| PAPERLESS_OCR_LANGUAGES | eng fra deu spa ita |

## Gotenberg container (when enabled)
- command: gotenberg --chromium-disable-javascript=true --chromium-allow-list=file:///tmp/.*
- probes http GET /health on 3000

## Tika container (when enabled)
- probes http GET / on 9998

## Security context
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Probes (main)
- liveness, startup, readiness: type http, httpHeaders Host: localhost (path not set in chart)

## Secrets
- secretKey (paperless.secretKey) placeholder "PLACEHOLDERSECRETKEYXXXXXXXXXXXX" (chart comment: MUST be changed, 32+ chars)
- env-secrets PAPERLESS_ADMIN_PASSWORD "admin"
