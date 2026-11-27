# TrueCharts tdarr values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tdarr/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/haveagitgat/tdarr`, tag `3.10.00@sha256:98137b694eed678f14ebc5f1d594d87ff8086df5cbc04203a15a53d95fe518b7`, pullPolicy IfNotPresent

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Ports
| service | port | notes |
| --- | --- | --- |
| main | 8265 | web UI (webUIPort) |
| comm | 8266 | server port (serverPort), enabled |

## Env (container main)
| env | value |
| --- | --- |
| webUIPort | service main port (8265) |
| serverPort | service comm port (8266) |
| internalNode | true |
| serverIP | 127.0.0.1 |
| nodeID | "Internal Node" |

## Persistence
| name | mountPath | notes |
| --- | --- | --- |
| configs | /app/configs | enabled |
| server | /app/server | enabled |
| logs | /app/logs | enabled |
| transcode-cache | /temp | enabled |
| media | /media | enabled |
| varrun | (default) | enabled, no mountPath set |
