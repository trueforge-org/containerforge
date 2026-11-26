# TrueCharts chart: kitana

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kitana (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kitana/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kitana/values.yaml
- Fetched 2026-11-26

## What it is
Chart `kitana` version `11.0.0`, `appVersion: latest`, not deprecated. Category home-automation; keywords include Tools-Utilities and MediaApp-Other. Depends on `common` `32.8.5`. Kubernetes `>=1.33.0-0`.
Description: exposes Plex plugin interfaces to the outside world via Plex.TV authentication and PMS proxying.

## Container
- `docker.io/pannal/kitana`, tag `latest@sha256:a6164e44a03bca92b07216412e564e9c445487fe739d1b80848ffe4b4c6ccd3b`, pullPolicy `IfNotPresent`.

## Security context
- container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No podSecurityContext.

## Env
- None present.

## Persistence
- `data` enabled, mountPath `/app/data`.

## Service / ports
- `main` service port `31337` -> targetPort `31337`, tcp.

## Probes
- None present.

## Gotchas
- Chart uses `/app/data` for sessions (upstream layout). Plan moves sessions to `/config/sessions` via a `/tmp` copy (plan section 7 and 9). Design difference.
