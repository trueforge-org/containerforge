# TrueCharts chart deepstack (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/deepstack (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/deepstack/values.yaml) · fetched 2026-11-26

## Images
- CPU: `docker.io/deepquestai/deepstack`, tag `cpu-2022.01.1@sha256:4320be73987468b3040b2ca63daf2d3935c4d469b53aa40efb6176858488b500`, IfNotPresent.
- `gpuImage`: same repo and the **same CPU tag and digest** (the GPU entry points at the CPU build; the chart's GPU option does nothing extra).

## Ports
Service main http port 10049 -> targetPort 5000.

## Env
- `MODELSTORE-DETECTION` = `/modelstore/detection`; `MODE` = `High` (comment lists High|Medium|Low); `THREADCOUNT` = 5; `API-KEY` and `ADMIN-KEY` empty.
- envFrom ConfigMap `deepstack` with `VISION-FACE`, `VISION-DETECTION`, `VISION-SCENE`, `VISION-ENHANCE` rendered as True/False from chart values (all true).

## Persistence
`data` -> `/datastore`; `modelstore` -> `/modelstore/detection` (types not stated).

## Security context
readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
Liveness, readiness, startup: http `/`.

## GPU
No GPU/device/runtime settings; the gpuImage is the CPU build.

## Gotchas
- Chart enables the four VISION-* APIs by default and sets MODE High, which differs from plan.md's `VISION-*` False defaults.
