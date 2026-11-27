# TrueCharts electrum values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/electrum/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/electrum`
- tag: `latest@sha256:91a90d3c0900e21437505a83aa1da1670afff8649edf30c26953e51cbde1649d`
- pullPolicy: IfNotPresent

## Ports
- service.main.ports.main: port 8080, targetPort 8080, protocol tcp (noVNC web)

## Env (set by chart)
| Name | Value |
| --- | --- |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 768 |
| DATA_PERM | 770 |

## Persistence
| Name | mountPath |
| --- | --- |
| datapath | /electrum |

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- Chart runs the ich777 image as root; wallet data at /electrum.
- Chart uses `latest` tag (digest-pinned) and appVersion `latest`; no Electrum version pin in the chart.
