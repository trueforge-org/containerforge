# TrueCharts chart codeproject-ai-server (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/codeproject-ai-server (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/codeproject-ai-server/values.yaml) · fetched 2026-11-26

## Images (digest pinned)
- `image`: `docker.io/codeproject/ai-server:cpu-2.6.5` (IfNotPresent) - CPU image selected for the main container.
- `gpu12Image`: `codeproject/ai-server:cuda12_2`; `gpu11Image`: `codeproject/ai-server:cuda11_7`. Not selected by any setting in values.

## Ports
Service main port 32168 (targetPort 32168; protocol unspecified).

## Env
None defined.

## Persistence
- `data` -> `/etc/codeproject/ai` (type not stated).
- `downloads` -> `/app/modules` (type not stated).

## Security context
runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes / GPU
No probes; no device, resource or GPU settings.

## Gotchas
- Chart pins `cpu-2.6.5`; plan.md's `2.9.5` native deb is a different line.
