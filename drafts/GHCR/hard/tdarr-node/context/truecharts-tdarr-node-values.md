# TrueCharts tdarr-node values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tdarr-node/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/haveagitgat/tdarr_node`, tag `3.10.00@sha256:36ef414f92f285dd97b9d1014f53aa6ebf7f8a1d2a73cc86e0832fd1c1e2d5bb`, pullPolicy IfNotPresent

## Service
- service main: enabled false (no web UI service exposed by default)

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Env (container main)
| env | value |
| --- | --- |
| nodeID | "myFirstTdarrNode" |
| serverIP | "0.0.0.0" |
| serverPort | 8266 |

Probes: liveness, readiness, startup all disabled.

## Persistence
| name | mountPath | notes |
| --- | --- | --- |
| configs | /app/configs | enabled |
| logs | /app/logs | enabled |
| transcode-cache | /temp | enabled |
| media | /media | enabled |
| varrun | (default) | enabled, no mountPath |
