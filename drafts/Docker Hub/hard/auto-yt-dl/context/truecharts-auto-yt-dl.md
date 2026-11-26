# TrueCharts chart: auto-yt-dl

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/auto-yt-dl/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/auto-yt-dl) · fetched 2026-11-26

## Container image
- repository `docker.io/guhu007/auto-yt-dl`
- tag `latest@sha256:eb3e4e838f8520d3786cafa44301f5441b08cf3b239a2a8727998de967e50854`
- pullPolicy `IfNotPresent`

## Ports
Service `main`, port entry `main`: port 5000, protocol tcp, targetPort 5000.

## Env vars
None.

## User/UID & permissions
`runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. `privileged` not set.

## Volumes/paths
- `data` persistence at `/app/data`.
- `hostpath1` persistence at `/app/Downloads`.

## Healthcheck/readiness
No probes defined.

## Gotchas
- Chart pins `latest` by digest, same as the Hub page.
- Chart's `/app/data` contents are not documented upstream (plan.md calls this UNVERIFIED; still unverified).

## Contradictions with plan.md
- None.
