# TrueCharts chart: vikunja

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vikunja (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/vikunja/vikunja`, tag `2.8.0@sha256:35d937ba...` (truncated), pullPolicy `IfNotPresent`.

## Env vars
- No explicit env blocks. Config is supplied via the `vikunja` values section, rendered as a secret `config` mounted at `/etc/vikunja/config.yaml`.
- JWT secret placeholder in the values is marked "Must be changed".

## Ports
- service main port `10220`, probes on `10220`. Differs from the upstream default `3456` (plan.md uses 3456; this is a chart override, not an error in the plan).

## Volumes/paths and persistent data
- `files` enabled, mounted at `/app/vikunja/files`.
- `vikunja-config` secret `config`, subPath `config.yaml`, mounted at `/etc/vikunja/config.yaml`.

## User/UID & permissions
- `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`, capability `NET_BIND_SERVICE` added.

## Healthcheck/readiness endpoints
- liveness, readiness and startup: HTTP `/health` on port 10220.

## Dependencies
- PostgreSQL enabled (user and database `vikunja`) and Valkey enabled.

## Gotchas
- Chart runs as root with a writable rootfs; plan.md uses `apps` (UID 568) and read-only rootfs.
- Chart config-file approach differs from the env-based plan (plan.md start.sh sets env vars, no config.yaml).
