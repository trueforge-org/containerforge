# TrueCharts cloud9 (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cloud9/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
Web IDE with terminal (Cloud9). Chart version 17.0.0, appVersion 1.29.2, category media (per annotation), train stable.

## Image
- repository: `ghcr.io/linuxserver/cloud9`
- tag: `version-1.29.2@sha256:45c5fe102ff3390bcd4ea58db99023b7ea099a8462f5727973ec329bd4a8d6b4`
- pullPolicy: IfNotPresent

## Service / ports
- service.main.ports.main: port 10070, protocol http, targetPort 8000

## Probes
- liveness, readiness, startup: http GET `/`

## Persistence
| name | enabled | mountPath |
| --- | --- | --- |
| code | true | /code |

## Security context
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0
- env: {} (none set)

## Chart deps
- `common` 32.8.5 from oci://oci.trueforge.org/truecharts; kubeVersion >=1.33.0-0

## Gotchas
- Chart targets container port 8000 and service port 10070; runs as root.
