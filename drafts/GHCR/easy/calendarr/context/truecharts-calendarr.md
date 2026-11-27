# TrueCharts calendarr (stable chart v4.0.0, appVersion latest)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calendarr/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calendarr/Chart.yaml (fetched 2026-11-27)

## What it is
- "Fetches upcoming airings/releases for TV shows and movies from Sonarr and Radarr calendars and posts them to Discord on a schedule."
- Chart sources: ghcr.io/jordanlambrecht/calendarr, github repo.
- Dependency: `common` 32.8.5.

## Image
- repository: `ghcr.io/jordanlambrecht/calendarr`
- tag: `latest@sha256:c2c197deafa80e9afda4a8140f0a98133d95c770e5a97c81ea7168f0b91bfc6e` (rolling latest, pinned by digest)
- pullPolicy: IfNotPresent

## Env vars (chart, all set from values)
| Name | Chart value / default |
| --- | --- |
| DEBUG | false |
| LOG_DIR | {{ persistence.logs.mountPath }} (/app/logs) |
| LOG_FILE | calendarr.log |
| LOG_BACKUP_COUNT | 15 |
| LOG_MAX_SIZE_MB | 1 |
| CALENDAR_URLS | list of {url, type} (type tv or movie); url empty by default |
| USE_DISCORD | false |
| DISCORD_WEBHOOK_URL | "" |
| DISCORD_HIDE_MENTION_INSTRUCTIONS | false |
| DISCORD_MENTION_ROLE_ID | "" |
| USE_SLACK | false |
| SLACK_WEBHOOK_URL | "" |
| CUSTOM_HEADER | "TV Guide - Shows and Movies airing this week" |
| ENABLE_CUSTOM_DISCORD_FOOTER / ENABLE_CUSTOM_SLACK_FOOTER | false |
| SHOW_DATE_RANGE | true |
| START_WEEK_ON_MONDAY | true |
| RUN_ON_STARTUP | true |
| CRON_SCHEDULE | "0 9 * * 1" |
| ADD_LEADING_ZERO | true |
| CALENDAR_RANGE | AUTO |
| DEDUPLICATE_EVENTS | true |
| DISPLAY_TIME | true |
| HTTP_TIMEOUT | 30 |
| PASSED_EVENT_HANDLING | STRIKE |
| RUN_TIME | "09:30" |
| SCHEDULE_DAY | 1 |
| SCHEDULE_TYPE | WEEKLY |
| SHOW_TIMEZONE_IN_SUBHEADER | true |
| USE_24_HOUR | true |

## Ports
- service.main is disabled in chart (no port exposed). Upstream EXPOSE 5000 (see github-calendarr-dockerfile.md).

## Volumes/paths (persistence)
| Name | Mount | Type |
| --- | --- | --- |
| logs | /app/logs | emptyDir |
| footers | /app/custom_footers | disabled by default; required if custom footer env enabled |

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Healthcheck
- liveness, readiness, startup all disabled.

## Gotchas
- Chart uses rolling latest tag; plan pins v1.5.2.
- Chart sets CRON_SCHEDULE and RUN_TIME/SCHEDULE_DAY; CRON_SCHEDULE overrides SCHEDULE_TYPE/DAY/RUN_TIME per chart comment.
