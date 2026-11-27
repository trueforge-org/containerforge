# TrueCharts digikam (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/digikam/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
digiKam photo management (desktop app streamed via Selkies). Chart version 19.0.1, appVersion 9.1.0, category media, train stable.

## Image
- repository: `ghcr.io/linuxserver/digikam`
- tag: `9.1.0@sha256:7814ddf4fd32f1540e56e1d6ff2b9e512dd08baa2c75f2e71a479dd174b5082b`
- pullPolicy: IfNotPresent

## Service / ports
- service.main.ports.main: port 10033, targetPort 3000 (no protocol set)

## Persistence
| name | enabled | mountPath |
| --- | --- | --- |
| config | true | /config |

## Security context
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0
- No env, probes or workload sections

## Chart deps
- `common` 32.8.5 from oci://oci.trueforge.org/truecharts; kubeVersion >=1.33.0-0

## Gotchas
- Chart targets port 3000 (HTTP, meant for reverse proxy); upstream Dockerfile EXPOSE 3001 only. See dockerhub/README file.
