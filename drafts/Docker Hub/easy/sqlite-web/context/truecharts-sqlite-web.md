# TrueCharts sqlite-web chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sqlite-web/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `sqlite-web`. Single `main` workload.

## Image used by chart
`docker.io/coleifer/sqlite-web` tag `latest@sha256:1e5b86237968ed747554f951c6df2fc2fe4bf4ef070b8ca23d553d7f6c6426f7`, pullPolicy IfNotPresent.

## Env vars set by chart
`SQLITE_DATABASE: db_name.db` (placeholder).

## Persistence
`data`: enabled, mountPath `/data`.

## Service
main port 8080, protocol tcp, targetPort 8080.

## Security
securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
None.

## Contradictions with plan.md
- Chart mounts `/data` (upstream path); plan.md mounts `/config`. Plan notes this in section 9.
- Chart sets `SQLITE_DATABASE`, which plan.md treats as an image-level variable.
