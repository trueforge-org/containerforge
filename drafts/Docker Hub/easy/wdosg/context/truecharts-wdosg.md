# TrueCharts chart: wdosg

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wdosg (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/soulraven1980/wdosg`, tag `latest@sha256:d5e93091...` (truncated), pullPolicy `IfNotPresent`.

## Env vars
- `PORT` = chart port value (3001).
- `TWITCH_CLIENT_ID` = `fake_client_id` (comment: required for IGDB credentials).
- `TWITCH_CLIENT_SECRET` from secret `env-secrets`, key `TWITCH_CLIENT_SECRET` (secret placeholder `fake_access_secret`).
- Note: the chart sets fake IGDB credentials, while plan.md defaults to `DISABLED`.

## Ports
- Service main, port 3001, protocol http.

## Volumes/paths and persistent data
- `database` at `/app/database`; `library` at `/app/wdosglibrary`.

## User/UID & permissions
- Not defined (no securityContext). Chart runs with the image default (root).

## Healthcheck
- Probes not defined.

## Gotchas
- plan.md sets `GAMES_LIBRARY=/config/wdosglibrary` and `DB_PATH=/config/database`. The chart mounts two separate paths. plan.md's single `/config` volume is a deliberate change; migrating users must follow the mapping (plan.md section 9).
