# TrueCharts chart: peanut (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/peanut/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 12.1.0, appVersion 6.2.0, library dep `common` 32.8.5
- "A Tiny Dashboard for Network UPS Tools."; category system; train stable
- kubeVersion >=1.33.0-0

## Image (values.yaml)
- repository: docker.io/brandawg93/peanut
- tag: 6.2.0@sha256:b6bf626143cff8bc2797dd42cb7b231de833fa9fda9b770321c623c71433ec28
- pullPolicy IfNotPresent

## Ports
| Service | Name | Port |
| --- | --- | --- |
| main | main | 10688 |

## Env (workload main, container main)
| Env | Value |
| --- | --- |
| WEB_PORT | {{ service.main.ports.main.port }} (10688) |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config (enabled) |

## Security context
- readOnlyRootFilesystem: false, runAsGroup: 0, runAsUser: 0 (chart runs as root)

## Probes
- none set in values.yaml (chart defaults)
