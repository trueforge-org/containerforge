# TrueCharts chart: ps3netsrv

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ps3netsrv (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ps3netsrv/values.yaml

## Image (chart values)
- repository `docker.io/shawly/ps3netsrv`, tag `v2.1.0@sha256:9848ba37e2a8dbcba0f1b29b788f3e25fa4cdb087e750dccacd1f578acb80491`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 38008, targetPort 38008, protocol tcp.

## Persistence
- `games`: mountPath `/games`, enabled.

## securityContext (container)
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Not defined
- No env vars, no probes.

## Gotchas
- Chart pins shawly's wrapper, not aldostools upstream. Chart version (v2.1.0) differs from draft's v2.0.1 claim in plan.md.
