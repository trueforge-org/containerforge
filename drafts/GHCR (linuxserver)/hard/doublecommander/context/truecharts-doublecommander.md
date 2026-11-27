# TrueCharts doublecommander (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/doublecommander/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
Double Commander two-panel file manager. Chart version 18.0.1, appVersion `latest`, category media, train stable.

## Image
- repository: `ghcr.io/linuxserver/doublecommander`
- tag: `latest@sha256:f25b7432b32ebecc06e26aa657c69a4d0f132fd39d4808653946402313ef9ba2`
- pullPolicy: IfNotPresent

## Service / ports
- service.main.ports.main: port 10034, targetPort 3000

## Workload
- container capabilities add: `SYS_CHROOT`, `KILL`, `NET_BIND_SERVICE`
- probes: liveness/readiness/startup http GET `/`
- env: none set

## Persistence
| name | enabled | mountPath |
| --- | --- | --- |
| config | true | /config |

## Security context
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Chart deps
- `common` 32.8.5 from oci://oci.trueforge.org/truecharts; kubeVersion >=1.33.0-0

## Gotchas
- Chart targets 3000 while upstream Dockerfile EXPOSE is 3001 (see Dockerfile file).
