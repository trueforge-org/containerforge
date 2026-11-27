# truecharts mojopaste (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mojopaste/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## Chart
- name mojopaste, chart version 11.0.0, appVersion `latest` (unpinned)
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; max helm 4.1, min helm 3.14; max k8s 1.35.0
- category: Cloud; sources: github.com/jhthorsen/app-mojopaste, docker hub jhthorsen/mojopaste

## Image (values.yaml)
- repository: docker.io/jhthorsen/mojopaste
- tag: latest@sha256:cbabffb2553418628948c397f2fde1662efd2a7559a6c24104b363c528299f97
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsUser: 0, runAsGroup: 0, readOnlyRootFilesystem: false

## Ports
- service main port 3300 (tcp) -> targetPort 8080

## Env (chart)
| var | value |
| --- | --- |
| PASTE_ENABLE_CHARTS | 0 |

## Persistence
| name | mountPath |
| --- | --- |
| data | /app/data |

## Probes / healthcheck
- none set in values.yaml
