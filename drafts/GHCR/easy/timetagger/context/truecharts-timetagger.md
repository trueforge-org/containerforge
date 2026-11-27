# TrueCharts chart: timetagger

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/timetagger/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `timetagger` v14.0.0, appVersion 26.1.3. Description: open-source time tracker with interactive UX and reporting. Category utilities.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/almarklein/timetagger`
- tag: `v26.1.3-nonroot@sha256:18a81afcb249142426fcff47bf9b54c343ca718a916f03d9722b84f8d7fafac6`
- pullPolicy: IfNotPresent

## Runtime security
- runAsUser 1000, runAsGroup 1000
- readOnlyRootFilesystem: false

## Ports
| name | port |
| --- | --- |
| main | 10286 |

## Persistence
| name | mountPath |
| --- | --- |
| config | /opt/_timetagger |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| TIMETAGGER_BIND | 0.0.0.0:{{ .Values.service.main.ports.main.port }} (0.0.0.0:10286) |

## Gotchas
- TIMETAGGER_BIND is not documented in the upstream README (fetched); treat as unverified.
- Mount path /opt/_timetagger is not in the fetched Dockerfile (WORKDIR /opt/timetagger); data location unverified.
- No probes, no secrets, no extra env in chart.
