# TrueCharts chart: aurora-files

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/aurora-files/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/aurora-files) · fetched 2026-11-26

## Container image
- repository `docker.io/afterlogic/docker-aurora-files`
- tag `latest@sha256:3252fd9aa134fa8284c02b9118587e1837aa3bf8d5292a1ce68bd9f232d761c5`
- pullPolicy `IfNotPresent`

## Ports
- Main service disabled (`enabled: false`), main port disabled. No port number set.

## Env vars
None defined.

## User/UID & permissions
`runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. `privileged` not set.

## Volumes/paths
`persistence: {}`: no entries.

## Healthcheck/readiness
Liveness, readiness, startup all disabled.

## Gotchas
- Chart pins `latest` by digest (`3252fd9a…`), the same digest the Hub page reports. Plan.md uses version `9.8.7` from master; the chart carries no version.
- The chart disables the service and probes, so it gives no port or probe data. Port 80 and `/fpm-ping` come from the upstream Dockerfile.

## Contradictions with plan.md
- None.
