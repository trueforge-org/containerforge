# TrueCharts chart: vlmcsd-kms-server

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vlmcsd-kms-server (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/mikolatero/vlmcsd`, tag `latest@sha256:aadb2a38...` (truncated), pullPolicy `IfNotPresent`.

## Security context
- `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`.

## Env vars, persistence, args
- None defined. No persistence. No args or command.

## Ports
- Service port 1688 -> 1688.

## Healthcheck
- liveness, readiness and startup all disabled.

## Gotchas
- Chart runs as root; plan.md runs as `apps` (UID 568) with read-only rootfs. vlmcsd is compatible (`-u`/`-g` exist, but plan.md uses `USER apps`).
- The chart uses the `latest` tag of `mikolatero/vlmcsd`, while plan.md builds from source (svn1113).
