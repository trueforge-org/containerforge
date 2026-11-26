# TrueCharts chart: victoriametrics

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/victoriametrics (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/victoriametrics/victoria-metrics`, tag `v1.157.0@sha256:322a7a92...` (truncated), pullPolicy `IfNotPresent`.
- Note: at fetch time the chart pins `v1.157.0`, not the `v1.156.0` the draft's links use.

## Env vars
- None defined.

## Ports
- Service main, port 8428 -> 8428.

## Volumes/paths and persistent data
- Persistence `data` enabled, mounted at `/victoria-metrics-data`, `targetSelectAll: true`.

## User/UID & permissions
- Not specified in values.yaml (no runAsUser, runAsGroup or readOnlyRootFilesystem).

## Healthcheck/readiness endpoints
- liveness and readiness: HTTP `/health`. startup disabled.

## Args or command
- None specified.

## Gotchas
- The chart does not set a security context, so the chart's runtime user is not pinned here (base chart library defaults may apply; not checked).
