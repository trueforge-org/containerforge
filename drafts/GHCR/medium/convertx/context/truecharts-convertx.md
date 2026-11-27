# TrueCharts convertx (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/convertx/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- ConvertX: self-hosted file converter. Chart version 3.0.0, appVersion 0.20.0. Category media.
- Dependency common 32.8.5 (oci://oci.trueforge.org/truecharts). Kube >=1.33.0-0.

## Image
- repository: ghcr.io/c4illin/convertx
- tag: v0.20.0@sha256:6259e0c1e063120b1ddbc6937372a83be58182b2c9dc82264f58e100907b3e51
- pullPolicy: IfNotPresent

## Ports
| Name | port | targetPort |
| --- | --- | --- |
| main | 3000 | 3000 |

## Persistence
| Name | mountPath |
| --- | --- |
| data | /app/data |

## Env
| Name | Value |
| --- | --- |
| HTTP_ALLOWED | "true" |

## Gotchas
- Chart sets no probes, no securityContext override in values.yaml.
