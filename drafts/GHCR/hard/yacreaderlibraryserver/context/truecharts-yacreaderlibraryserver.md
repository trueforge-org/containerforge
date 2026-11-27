# TrueCharts chart: yacreaderlibraryserver

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yacreaderlibraryserver/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/xthursdayx/yacreaderlibrary-server-docker` (headless YACReaderLibraryServer).
- Chart `version: 11.0.0`, `appVersion: latest`, category MediaServer-Other, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/xthursdayx/yacreaderlibrary-server-docker`, `tag: latest@sha256:5c4c7fb8...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 8080 | 8080 (tcp) |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| comics | /comics | enabled |
| config | /config | enabled |

## Env vars, probes, secrets
- None defined in values.yaml. No probes defined.

## User/UID
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.
- Upstream image uses PUID/PGID (s6 init, see upstream README).

## Gotchas
- Chart runs as root with writable rootfs; upstream PUID/PGID not set in chart.
