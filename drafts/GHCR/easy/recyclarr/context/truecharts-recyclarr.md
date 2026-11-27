# TrueCharts recyclarr chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/recyclarr/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/recyclarr/Chart.yaml
- Fetched 2026-11-27

## What it is
- "A command-line application that will automatically synchronize recommended settings from TRaSH guides to your Sonarr/Radarr instances." Chart 17.0.0, appVersion 8.8.1, keywords Tools-Utilities
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/recyclarr/recyclarr, github recyclarr/recyclarr (+ pkgs page)

## Image (values.yaml)
- repository: `ghcr.io/recyclarr/recyclarr` (GHCR, no Docker Hub source)
- tag: `8.8.1@sha256:3e9c41b9ec29bbf65fe846864058730d321a21f7695d8c0d9437b73e34d50ad9`

## Service
- service.main disabled (no ports)

## Workloads
- initContainer `initconfig` (type install, imageSelector image): command `recyclarr config create`
- main container: probes liveness/readiness/startup disabled; env `CRON_SCHEDULE: "@daily"`

## Persistence
| Name | Mount | Notes |
| --- | --- | --- |
| config | /config | targetSelectAll true |

## Gotchas
- No securityContext override in values (chart defaults apply).
- Init container runs `recyclarr config create` on every pod start; behaviour when config exists not verified here (Dockerfile entrypoint only creates when RECYCLARR_CREATE_CONFIG=true and file missing).
