# TrueCharts chart: tachidesk-docker

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tachidesk-docker/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `tachidesk-docker` v12.0.0. Description "The official Tachidesk Chart-Chart." Category MediaServer-Other.
- Chart `appVersion: preiew` (typo in upstream chart, unverified impact).
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/suwayomi/tachidesk`
- tag: `preview@sha256:27dd1b51c0497b8ed4ed7c22f8564483990ce04b376cacb73eab419e80022b75`
- pullPolicy: IfNotPresent

## Runtime security
- readOnlyRootFilesystem: false (no runAsUser set in values; image USER is suwayomi uid 1000)

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 4567 | (default) |

## Persistence
| name | mountPath |
| --- | --- |
| appdata | /home/suwayomi/.local/share/Tachidesk |
| library | /home/suwayomi/.local/share/Tachidesk/downloads |
| local-library | /home/suwayomi/.local/share/Tachidesk/local |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| BIND_IP | "0.0.0.0" |
| BIND_PORT | "{{ .Values.service.main.ports.main.port }}" (4567) |
| SOCKS_PROXY_ENABLED | false |
| SOCKS_PROXY_HOST | "" |
| SOCKS_PROXY_PORT | "" |
| DOWNLOAD_AS_CBZ | true |
| BASIC_AUTH_ENABLED | false |
| BASIC_AUTH_USERNAME | "" |
| BASIC_AUTH_PASSWORD | secretKeyRef env-secrets/BASIC_AUTH_PASSWORD |
| DEBUG | false |
| GQL_DEBUG | false |
| WEB_UI_ENABLED | true |
| WEB_UI_FLAVOR | "WebUI" |
| WEB_UI_CHANNEL | "stable" |
| WEB_UI_UPDATE_INTERVAL | 23 |
| AUTO_DOWNLOAD_CHAPTERS | false |
| AUTO_DOWNLOAD_EXCLUDE_UNREAD | true |
| AUTO_DOWNLOAD_AHEAD_LIMIT | 0 |
| EXTENSION_REPOS | "" |
| MAX_SOURCES_IN_PARALLEL | 6 |
| UPDATE_EXCLUDE_UNREAD | true |
| UPDATE_EXCLUDE_STARTED | true |
| UPDATE_EXCLUDE_COMPLETED | true |
| UPDATE_INTERVAL | 12 |
| UPDATE_MANGA_INFO | false |
| BACKUP_INTERVAL | 1 |
| BACKUP_TTL | 14 |
| FLARESOLVERR_ENABLED | false |
| FLARESOLVERR_URL | "" |
| FLARESOLVERR_TIMEOUT | 60 |
| FLARESOLVERR_SESSION_NAME | "suwayomi" |
| FLARESOLVERR_SESSION_TTL | 15 |

Secret `env-secrets` (enabled): BASIC_AUTH_PASSWORD "".

## Gotchas
- Several chart env names (e.g. AUTO_DOWNLOAD_*, UPDATE_EXCLUDE_*, BACKUP_TTL, EXTENSION_REPOS, FLARESOLVERR_*) are not handled by the startup script fetched from the docker-tachidesk commit 7a2bdee (see github-docker-tachidesk-scripts.md); only the variables the script maps to server.conf take effect there.
- Probes not set in values.yaml.
