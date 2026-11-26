# TrueCharts chart: webp-server

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webp-server (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/webpsh/webps`, tag `latest@sha256:3b9e2e53...` (truncated), pullPolicy `IfNotPresent`.

## Security context
- `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`.

## Env vars
- `ALLOWED_TYPES` = `jpg,png,jpeg,bmp,gif`
- `ENABLE_AVIF` = `false`
- `QUALITY` = `80`
- Note: no WEBP_* variables are set by the chart.

## Ports
- Service main, port 3333, protocol tcp.

## Volumes/paths and persistent data
- `storagecache` at `/opt/exhaust` (enabled).
- `storagepics` at `/opt/pics` (enabled, readOnly true).

## Probes, args, config mounts
- None defined.

## Gotchas
- Chart runs as root with writable rootfs. Chart keys (ALLOWED_TYPES, ENABLE_AVIF) are not env vars of the 0.16.2 binary as far as the fetched config.json shows; the chart's env may not take effect. Not verified.
- The chart mounts `/opt/exhaust` and `/opt/pics`; plan.md uses `/tmp/exhaust` as the cache, per its design (ephemeral).
