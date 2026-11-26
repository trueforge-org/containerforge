# TrueCharts chart: notarius

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/notarius/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/notarius/Chart.yaml (2026-11-26)

## What it is
Chart version 11.0.0, `appVersion: latest`, category Other, description "No description provide." (sic). Library dep `common` 32.8.5.

## Image
- `docker.io/agusalex/notarius`, tag `latest@sha256:ac7f357fc114660429b2b08f8939cf3bcbe7a0cc399a46077b77d417500a6ab4`, pullPolicy IfNotPresent

## Ports / service
- service `main`: `enabled: false`, port `main` `enabled: false`. No port exposed by the chart.

## Probes
- liveness, readiness, startup: all `enabled: false`.

## Env vars
- None set in values.yaml.

## Persistence
- `persistence: {}` (none).

## Security
- securityContext.container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Gotchas
- Chart has no service, no probes, no env. Runtime port is not defined in chart values.
- Runs as root with a writable rootfs.
