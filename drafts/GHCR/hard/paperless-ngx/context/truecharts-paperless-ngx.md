# TrueCharts chart: paperless-ngx

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `paperless-ngx` v19.2.0, appVersion 3.5.1, category productivity.
- Chart pulls in dependencies `valkey` (enabled) and `postgresql` (enabled, username/db `paperless-ng`); tika and gotenberg are OFF (`tika.enabled: false`).
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Images
| Key | Repository | Tag |
| --- | --- | --- |
| image | ghcr.io/paperless-ngx/paperless-ngx | 3.5.1@sha256:8508853b8a0f8394074260957d0be186c8c64f346973b24a7583de4580f306b9 |
| gotenbergImage | docker.io/gotenberg/gotenberg | 9.10@sha256:2ce6fcd3f5019c82b0376065b9103d6d4938d34c1c06a39a8263a9fcf47a6f5b |
| tikaImage | docker.io/apache/tika | 3.4.0.0@sha256:9f3e5bb9da4229a971a4839416b3204499f20668ee834fa741a6a7504bbea7bf |

## Service / ports
| Name | port | targetPort | Notes |
| --- | --- | --- | --- |
| main | 10140 | 8000 | web |
| gotenberg | 3000 | 3000 | enabled when tika.enabled |
| tika | 9998 | 9998 | enabled when tika.enabled |

## Persistence
| Name | mountPath | Notes |
| --- | --- | --- |
| data | /data | enabled |
| consume | /consume | enabled |
| media | /media | enabled |
| varrun | (none) | disabled |

## Env (container main)
| Env | Value |
| --- | --- |
| PAPERLESS_PORT | 8000 (targetPort) |
| PAPERLESS_DATA_DIR | /data/ |
| PAPERLESS_CONSUMPTION_DIR | /consume/ |
| PAPERLESS_MEDIA_ROOT | /media/ |
| PAPERLESS_URL | "" |
| USERMAP_UID | securityContext.container.PUID (empty default) |
| USERMAP_GID | securityContext.pod.fsGroup |
| PAPERLESS_TIME_ZONE | TZ |
| PAPERLESS_DBENGINE | postgresql |
| PAPERLESS_DBNAME | paperless-ng |
| PAPERLESS_DBUSER | paperless-ng |
| PAPERLESS_DBPORT | 5432 |
| PAPERLESS_DBHOST | secret `<release>-postgresqlcreds` key plainhost |
| PAPERLESS_DBPASS | secret `<release>-postgresqlcreds` key postgresql-password |
| PAPERLESS_REDIS | secret `<release>-valkeycreds` key url |
| PAPERLESS_SECRET_KEY | secret `secrets` key PAPERLESS_SECRET_KEY (values.paperless.secretKey placeholder) |
| PAPERLESS_TIKA_ENABLED | 0 (tika.enabled false) |
| PAPERLESS_TIKA_GOTENBERG_ENDPOINT | http://<fullname>-gotenberg:3000 |
| PAPERLESS_TIKA_ENDPOINT | http://<fullname>-tika:9998 |
| PAPERLESS_WEBSERVER_WORKERS | 2 |
| PAPERLESS_ADMIN_USER | admin |
| PAPERLESS_ADMIN_PASSWORD | secret `env-secrets` key PAPERLESS_ADMIN_PASSWORD (default "admin") |
| PAPERLESS_ADMIN_MAIL | admin@admin.com |
| PAPERLESS_OCR_LANGUAGE | eng |
| PAPERLESS_OCR_LANGUAGES | eng fra deu spa ita |

## Probes (main)
- liveness, startup, readiness: HTTP, header Host: localhost.

## Gotenberg / Tika (only when tika.enabled)
- gotenberg: command `gotenberg --chromium-disable-javascript=true --chromium-allow-list=file:///tmp/.*`; probes HTTP /health on port 3000.
- tika: probes HTTP / on 9998.

## Security
- runAsUser 0; runAsGroup 0; runAsNonRoot false; readOnlyRootFilesystem false.

## Gotchas
- Chart pins paperless data/media/consume at /data, /media, /consume, not /config or /usr/src/paperless/*.
- Chart admin password default "admin" in secret.
- Chart adds PAPERLESS_OCR_LANGUAGES, PAPERLESS_ADMIN_* envs not in plan's env list.
