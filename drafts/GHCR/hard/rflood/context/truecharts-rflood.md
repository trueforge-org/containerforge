# TrueCharts chart: rflood

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rflood/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `rflood` (appVersion `latest`), train stable, category Downloaders.
- Description: chart with rTorrent and the Flood web UI.
- Dependency: `common` 32.8.5.

## Image
- repository: `ghcr.io/hotio/rflood`
- tag: `latest@sha256:92e3c258699714bae99c7471ccf256ef03afb085b1e05fe7cfbc0a3b0c806acb` (pullPolicy IfNotPresent)

## Ports
| name | port | target | proto |
| --- | --- | --- | --- |
| main | 3000 | 3000 | http |

## Env (chart-set)
| var | value |
| --- | --- |
| FLOOD_AUTH | "false" |

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- No probes or data mount in values.
- Chart pins `latest` by digest, not a release tag.
