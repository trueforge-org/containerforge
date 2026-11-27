# TrueCharts chart: homer (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homer/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
Chart `homer` v17.0.0, appVersion 26.11.2, library dependency `common` 32.8.5. Static homepage dashboard.

## Runtime / image
- image: `ghcr.io/bastienwirtz/homer`, tag `v26.11.2@sha256:ce91f7506b0bf04d18e76bc193281e450c0b6e9b9bc5dae5639468e06dd7eaae`, pullPolicy IfNotPresent
- Source: https://github.com/bastienwirtz/homer (upstream image, not Docker Hub)

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 10178 | 8080 |

## Volumes / paths
- persistence `config`: enabled, mountPath `/www/assets`

## User/UID
- securityContext.container: runAsUser 1000, runAsGroup 1000

## Env vars
| name | value |
| --- | --- |
| INIT_ASSETS | true |

## Kube
- kubeVersion `>=1.33.0-0`; no probes overridden in values.yaml

## Gotchas
- Chart tag (v26.11.2) is one release behind plan target v26.11.4.
- Chart `values.yaml` has no probes, no SUBFOLDER, no PORT override.
