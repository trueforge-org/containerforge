# TrueCharts chart: unpoller

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/unpoller/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `unpoller` v19.0.2, appVersion 5.10.2. Description: collects UniFi controller data and reports to InfluxDB or exports for Prometheus. Category metrics.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/unpoller/unpoller`
- tag: `v5.10.2@sha256:1bd77eecb10f00c2f57d33a63fc1b3ccca73f3b5f0a9d13d2f9ab467e32bd6fb`
- pullPolicy: IfNotPresent

## Ports
| name | port |
| --- | --- |
| main | 9130 |

## Metrics (values.yaml)
- metrics.main enabled, type servicemonitor, endpoint port `main`, path `/metrics`, prometheusRule disabled.

## Probes (values.yaml)
- liveness, readiness, startup: HTTP path `/` (no port/other settings in values).

## Env vars (chart values)
| Env | Value |
| --- | --- |
| UP_PROMETHEUS_DISABLE | false |
- Commented-out: UP_UNIFI_DEFAULT_URL, UP_UNIFI_DEFAULT_USER, UP_UNIFI_DEFAULT_PASS (not set).

## ConfigMap
- `dashboards` configmap (enabled, label grafana_dashboard "1") with 6 JSON dashboards from chart `dashboards/` dir: UAP, clients, USW, network, USG, DPI.

## Security context
- readOnlyRootFilesystem: false (not set further; no runAsUser in values).

## Gotchas
- Chart sets no UniFi credentials; user must supply UP_UNIFI_DEFAULT_* or a config file.
- Probes hit `/`; upstream docs say /metrics is the Prometheus endpoint (see github-unpoller-example-config.md). `/` response not verified.
