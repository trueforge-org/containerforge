# TrueCharts static-web-server values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/static-web-server/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/static-web-server/static-web-server`
- tag: `2.44.3@sha256:ccf2d666ffe5f8ef2ec96bc40f07757605998c04b78f7d8fdb98a584dd4f5717`
- pullPolicy: IfNotPresent

## Ports
- service main port `38080` (protocol http)

## Env vars
- SERVER_PORT: from service port value (`38080`)
- SERVER_ROOT: `/public`

## Volumes/paths
- config → `/public`

## Probes
- liveness, readiness, startup: tcp

## User/UID, securityContext
- not specified (no runAsUser/fsGroup/readOnlyRootFilesystem)
