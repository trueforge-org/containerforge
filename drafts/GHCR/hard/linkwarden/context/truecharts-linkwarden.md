# TrueCharts linkwarden (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkwarden/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `linkwarden` v10.0.0, appVersion 2.17.0
- Description: self-hosted collaborative bookmark manager (collect, organize, archive webpages)

## Image
- repository ghcr.io/linkwarden/linkwarden, tag v2.17.0 (digest pinned), pullPolicy IfNotPresent

## Env vars (workload main)
| Var | Source |
| --- | --- |
| DATABASE_URL | secret `<release>-postgresqlcreds`, key url |
| NEXTAUTH_SECRET | secret `linkwarden-secrets`, key NEXTAUTH_SECRET (chart value linkwarden.nextauthSecret, placeholder "PLACEHOLDERNEXTAUTHSECRETCHANGEME", must change) |
| NEXTAUTH_URL | config.nextauth_url (default "http://example.com") |
| PAGINATION_TAKE_COUNT | config.pagination_take_count (20) |
| STORAGE_FOLDER | "data" |
| AUTOSCROLL_TIMEOUT | config.autoscroll_timeout (30) |
| NEXT_PUBLIC_DISABLE_REGISTRATION | config.disable_registration (false) |
| RE_ARCHIVE_LIMIT | config.archive_limit (5) |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 2985 | 3000 |

## Volumes/paths
- data -> /data/data (persistent)

## Runtime deps
- PostgreSQL (dependencies.postgresql enabled; db linkwarden, user linkwarden)

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck
- Not overridden in values (image HEALTHCHECK curl http://127.0.0.1:3000/ per upstream Dockerfile)

## Gotchas
- nextauthSecret placeholder must be replaced by user.
