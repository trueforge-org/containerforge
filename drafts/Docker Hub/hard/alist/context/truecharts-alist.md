# TrueCharts chart: alist

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alist/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/alist) · fetched 2026-11-26

## Container image
- repository `docker.io/xhofe/alist-aria2`
- tag `v3.41.0@sha256:573e8862f6893804fd4a98781e269459f0d69fa148ede371afd2bf58a2dda289`
- pullPolicy `IfNotPresent`

## Ports
- Main service: targetPort `5244`, protocol http, port `10167`.
- Second service (aria2): enabled, targetPort `6800`, protocol http, port `6800`.

## Env vars
None set (`env: {}`).

## User/UID & permissions
`runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`. `privileged` not specified.

## Volumes/paths
Persistence `data` mounted at `/opt/alist/data`. No other persistence entries.

## Healthcheck/readiness endpoints
liveness, readiness and startup probes: type http, path `/`.

## Gotchas
- Chart uses the aria2-bundled image and exposes aria2 as a second service. Plan.md section 9 says the chart persisted `/opt/alist/data`: consistent.
- Chart tag `v3.41.0` (stale vs `v3.66.0` in plan.md section 1). Recorded in plan.md already.

## Contradictions with plan.md
- None on ports or user.
