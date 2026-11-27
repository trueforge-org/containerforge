# TrueCharts chart: sia-daemon (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sia-daemon/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `sia-daemon` v11.0.0, appVersion `master`, category Cloud, depends on `common` 32.8.5.
- Description: Sia decentralised cloud storage (smart contracts, client-side encryption, Reed-Solomon redundancy).
- Sources: https://ghcr.io/siafoundation/siad , https://github.com/SiaFoundation/siad

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/siafoundation/siad |
| tag | master@sha256:be7850f0389a6a68ae86181e1e1363328062f76777ce5bcfb3ae3a7ca314cd03 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 9981 | 9981 | tcp |
| hostrhp2port | 9982 | 9982 | tcp |
| hostrhp3port | 9983 | 9983 | tcp |

## Persistence
- `datadirectory`: enabled, mountPath `/sia-data`

## Container env (chart override)
| Name | Value |
| --- | --- |
| SIA_API_PASSWORD | secretKeyRef env-secrets/SIA_API_PASSWORD |
| SIA_WALLET_PASSWORD | secretKeyRef env-secrets/SIA_WALLET_PASSWORD |

Secret `env-secrets` (enabled): keys `SIA_API_PASSWORD: ""`, `SIA_WALLET_PASSWORD: ""`.

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
