# TrueCharts chart: scrypted

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/scrypted/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/scrypted/values.yaml (fetched 2026-11-27)

## What it is
- Chart v10.0.0, appVersion 0.123.58. Category media.
- "Scrypted is a high performance home video integration and automation platform."
- Sources: ghcr.io/koush/scrypted, github koush/scrypted.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Images (values.yaml), all pullPolicy Always
| variant | repository | tag |
| --- | --- | --- |
| main (full) | ghcr.io/koush/scrypted | v0.123.58-jammy-full@sha256:d84d2a8c...22b3 |
| lite | ghcr.io/koush/scrypted | v0.123.58-jammy-lite@sha256:63f28be6...0fdc |
| nvidia | ghcr.io/koush/scrypted | v0.123.58-jammy-nvidia@sha256:47a9b733...b309 |

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 10611 | http (SCRYPTED_INSECURE_PORT) |

Commented-out in chart: SCRYPTED_WEBHOOK_UPDATE_AUTHORIZATION, SCRYPTED_WEBHOOK_UPDATE (http://localhost:10444/v1/update).

## Env (container main, set by chart)
| key | value |
| --- | --- |
| SCRYPTED_INSECURE_PORT | 10611 (from service port) |

## Persistence
| name | mountPath |
| --- | --- |
| server | /server/volume |
| media | /media/external |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Gotchas
- Chart selects variant via imageSelector `image` (full); liteImage and nvidiaImage defined but not selected for main.
- Chart runs as root.
