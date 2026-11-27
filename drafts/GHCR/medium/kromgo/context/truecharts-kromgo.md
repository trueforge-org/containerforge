# TrueCharts chart: kromgo

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kromgo/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "A simple go project that allows you to expose prometheus metrics safely to a public source." Chart 5.0.0, `appVersion 0.16.4`. Keywords: kromgo, metrics, prometheus, grafana, shields.io.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- Repository `ghcr.io/home-operations/kromgo`
- Tag `0.16.4@sha256:f55f7b5590a394e3ea47f5debf8c75e01898c3f915331aa28568b6fd8d426310`, pullPolicy IfNotPresent.

## Ports
| Name | Port | Note |
| --- | --- | --- |
| main | 80 | KROMGO_SERVER_PORT |
| health | 8080 (enabled) | KROMGO_HEALTH_PORT |

## Env vars (chart)
| Name | Value |
| --- | --- |
| KROMGO_PROMETHEUS_URL | `http://prometheus-operated.kube-prometheus-stack.svc.cluster.local:9090` (hardcoded in chart) |
| KROMGO_SERVER_PORT | `{{ service.main.ports.main.port }}` (80) |
| KROMGO_HEALTH_PORT | `{{ service.main.ports.health.port }}` (8080) |

- Chart has commented-out env entries: KROMGO_SERVER_LOGGING, KROMGO_SERVER_READ_TIMEOUT, KROGMO_SERVER_WRITE_TIMEOUT, KROGMO_QUERY_TIMEOUT, KROGMO_LOG_LEVEL, KROGMO_LOG_FORMAT (typos in chart comments).

## Probes
- liveness `/healthz`, readiness `/readyz`, startup `/readyz` (all HTTP).

## Config
- ConfigMap `kromgo-configfile` with `config.yaml` rendered from `kromgo:` values (`defaults`, `badges`, `graph`). Mounted read-only at `/config/config.yaml` (subPath).
- Badges set: talos_version (`node_os_info{name="Talos"}`), kubernetes_version (`kubernetes_build_info`), flux_version (`gotk_resource_info` with label_replace).
- Defaults: badge font dejavu-sans, size 11, style flat; graph maxDuration 1h, width 600, height 200, legend true, theme light.

## Gotchas
- `KROMGO_HEALTH_PORT` is set by the chart but is NOT in upstream README env table (see GitHub file).
- Chart main port 80 vs upstream default 8080 (`KROMGO_SERVER_PORT`).
