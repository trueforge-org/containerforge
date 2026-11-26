# TrueCharts chart: xmrig

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xmrig (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/cooleye72/xmrig`, tag `6.21@sha256:f7e590b2...` (truncated), pullPolicy `IfNotPresent`.

## Security context
- `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. `privileged` not set in the file.

## Env vars
- `ADDITIONAL` = `--no-color `
- `ALGO_MODE` = `rx/0`
- `POOL_URL` = `gulf.moneroocean.stream:10128`
- `YOUR_ADDRESS` = `""` (must be filled in)
- `YOUR_WORKER_NAME` = `TrueNAS`

## Ports, persistence, probes, args
- Service and port disabled. No persistence (`persistence: {}`). Liveness, readiness and startup probes disabled. No args or command.

## Gotchas
- The chart's default pool differs from the Docker Hub example (`rx.unmineable.com:3333`). Neither is used by plan.md.
- plan.md section 1 says the chart pins `6.21` (confirmed).
