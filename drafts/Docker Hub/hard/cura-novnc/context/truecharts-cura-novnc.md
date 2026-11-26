# TrueCharts chart cura-novnc (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cura-novnc (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cura-novnc/values.yaml) · fetched 2026-11-26

## Image
`docker.io/mikeah/cura-novnc:5.8.1` pinned by digest (`4a8f18baf…01a4`), IfNotPresent.

## Ports
Service main http port **16081**, targetPort 8080.

## Env
Empty map.

## Persistence
- `homefolder` -> `/home/cura/`; `prints` -> `/prints/` (types not stated).

## Security context
readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
Liveness, readiness, startup: http `/`.

## Resources
Limits CPU 4000m, memory 6000Mi; requests CPU 400m, memory 1000Mi.

## Gotchas
- Chart's service port 16081 maps to container 8080 (easy-novnc). Plan's 3000/3001 come from kasmvnc.
