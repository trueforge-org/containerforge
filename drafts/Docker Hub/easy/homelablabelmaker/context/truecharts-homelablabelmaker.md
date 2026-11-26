# TrueCharts chart: homelablabelmaker

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/homelablabelmaker (chart dir); values read from https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homelablabelmaker/values.yaml · fetched 2026-11-26

## What it is
TrueCharts Helm chart for homelablabelmaker, using `docker.io/davidspek/homelablabelmaker`.

## Container settings in the chart
- Image repository: `docker.io/davidspek/homelablabelmaker`, tag `latest@sha256:00c441e62856d1de6b5580d19d4f207d2ca6832dbac79aa2084b15b62a663bac`, pullPolicy `IfNotPresent`.
- runAsUser / runAsGroup: `0`; runAsNonRoot: `false`; readOnlyRootFilesystem: `false`; privileged not set.

## Env vars (table)
- None defined.

## Ports
- Service port `10581` (http) to targetPort `80`. The upstream image listens on container port 80.

## Volumes/paths and persistent data
- No persistence entries.

## Gotchas
- Chart targets container port 80. Plan.md uses 8080 (nginx base default). This is a deliberate ContainerForge change, not a contradiction of the upstream image.
