# TrueCharts chart: barcodebuddy

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/barcodebuddy/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/barcodebuddy) · fetched 2026-11-26

## Container image
- repository `docker.io/f0rc3/barcodebuddy`
- tag `latest@sha256:f2496ffce1c2b8216be6a8046255fd546b495ef8c98458b47099710341830d5a`
- pullPolicy `IfNotPresent`

## Ports
Service main: port `8450`, tcp, targetPort `80`.

## Env vars
None defined.

## User/UID & permissions
`runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. `privileged` not set.

## Volumes/paths
`config` persistence at `/config`.

## Devices / hostPath
None defined (no `/dev/input` mapping in the chart; the input grabber needs input devices per plan.md).

## Healthcheck/readiness
No probes defined.

## Contradictions with plan.md
- None. Port 80 target and `/config` volume match plan.md section 1.
