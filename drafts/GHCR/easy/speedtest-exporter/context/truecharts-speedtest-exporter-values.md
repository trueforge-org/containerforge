# TrueCharts speedtest-exporter values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/speedtest-exporter/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/miguelndecarvalho/speedtest-exporter`
- tag: `v3.5.4@sha256:f1064d49124c7fc45faabb87c6c876a2fd04e92b3dc14d4b871301217ba30fed`
- pullPolicy: IfNotPresent

## Ports
- service main port `9798` (protocol not stated)

## Env vars
- SPEEDTEST_PORT: `9798` (from service port value)

## Metrics
- servicemonitor enabled, endpoint port `main`, path `/metrics`, interval 1h, scrapeTimeout 60s
- prometheusRule disabled
- dashboard configmap enabled (label `grafana_dashboard: "1"`, data `speedtest.json` from `dashboard.json`)

## Volumes/paths
- none defined

## User/UID, probes, securityContext
- securityContext: runAsUser 1000, runAsGroup 1000, readOnlyRootFilesystem false, fsGroup not set
- No probes defined.
