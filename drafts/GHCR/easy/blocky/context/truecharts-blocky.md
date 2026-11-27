# TrueCharts blocky (stable chart v25.0.0, appVersion 0.37.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blocky/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blocky/Chart.yaml (fetched 2026-11-27)

## What it is
- "Blocky is a DNS proxy, DNS enhancer and ad-blocker for the local network written in Go."
- Chart sources: 0xerr0r.github.io/blocky, ghcr.io/0xerr0r/blocky, github repo, Mozart409/blocky-frontend (third-party).
- Dependencies: `common` 32.8.5; subcharts `valkey` (enabled) and `postgresql` (enabled, depconfig user/db blocky).

## Image
- repository: `ghcr.io/0xerr0r/blocky`
- tag: `v0.37.0@sha256:d9b6344d7c8f3fe577a47bc97b523faa116f7ea8a8901bfaf800a4dbdce64c96`
- Companion (out of scope per plan): `codeberg.org/k8s-gateway/k8s_gateway:1.10.0@sha256:007636...` (k8sgatewayImage, separate sidecar).

## Env vars (chart)
- No env block in chart values. Chart sets config via `blockyConfig` / values, not env.

## Ports (chart service)
| Service | Port | Proto |
| --- | --- | --- |
| main | 4000 | http |
| dns (udp) | 53 | udp |
| dnstcp | 53 (targetPort 53) | tcp |
| dot | 853 | tcp |
| https | 4443 | https |
| k8sgateway | 5353 | udp |

## Probes
- liveness, readiness, startup: all disabled; exec `/app/blocky healthcheck`.

## Workload
- replicas: 2; strategy RollingUpdate.

## Config (values -> blocky config)
- `logLevel: info`, `logFormat: text`, `logTimestamp: true`, `logPrivacy: false`
- `defaultUpstreams`: 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4, 9.9.9.9, 149.112.112.112, 208.67.222.222, 208.67.220.220, 8.26.56.26, 8.20.247.20
- `upstreamTimeout: 1s`, `minTlsServeVersion: 1.2`
- `caching`: minTime 15m, prefetching true, prefetchExpires 12h
- `blocking`: blockType nxDomain, blockTTL 6h, refreshPeriod 4h, startStrategy fast, maxErrorsPerSource 5
- `queryLog.type: postgresql` (chart default); logRetentionDays 0
- `metrics.main`: servicemonitor on port main, path /metrics

## Volumes/paths
- none in chart persistence block; configmap dashboard (blocky.json, blockypostgres.json) and grafana datasource secret only.

## Gotchas
- Chart uses v0.37.0 (draft in plan says v0.36.0 is the draft tag; this chart already tracks 0.37.0).
- Chart ports include TCP/UDP 53 and 853/4443, which differ from the ContainerForge plan (5353, 4000).
- k8s_gateway sidecar is a separate image; not part of blocky container.
