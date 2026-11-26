# TrueCharts xware chart (reference only)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xware/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xware/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xware not parsed (raw files used).

## What it is
- Helm chart `xware`, chart version 11.0.0, appVersion `latest`. Description: "This is a Chart of Thunder downloader."
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image (values.yaml)
- repository `docker.io/caiguai/docker-xware`
- tag `latest@sha256:0aea5c81ecbe16258f324926cbcf8a0b8b460d8b4be3bbe9c2e06c0df92dadf5`

## Service
- `service.main.enabled: false` (no service)
- `persistence: {}` (none)

## Security context
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Probes
- liveness, readiness, startup: all disabled

## Gotchas
- Chart disables service and probes; no port exposed by the chart.
