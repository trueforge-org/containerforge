# TrueCharts tasmoadmin values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tasmoadmin/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/tasmoadmin/tasmoadmin`, tag `v5.1.0@sha256:87820bbb28e777875f747ca8efea092d5f88a8e07cfedad9bb3c865106855774`, pullPolicy IfNotPresent

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Ports
- service main: port 9541, protocol http, targetPort 80

## Env (container main)
- TASMO_DEBUG: 1

## Persistence
- data: enabled, mountPath /data
