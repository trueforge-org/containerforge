# TrueCharts shortipy chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shortipy/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `shortipy`. Single `main` workload.

## Image used by chart
`docker.io/knex666/shortipy` tag `latest@sha256:7cd696ae789fc6e0e092c7af2db99ee9f2f14c888ace05883f50001a6fe7dbf2`, pullPolicy IfNotPresent.

## Security
securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Persistence
Empty (`persistence: {}`). The chart defines no volume.

## Env
No env section.

## Service / probes
Service main disabled (main port disabled). Liveness, readiness and startup probes disabled.

## Contradictions with plan.md
- Chart runs as root (matches plan.md's "runAsUser 0" expectation).
- Chart defines no persistence, so no volume is mounted for `data/db.json` in the chart; plan.md's `/config` volume is a ContainerForge choice.
