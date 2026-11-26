# TrueCharts seafile chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/seafile (WebFetch 2026-11-26); values.yaml via raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/seafile/values.yaml (2026-11-26).

## Facts from values.yaml
- Image: `docker.io/seafileltd/seafile-mc`, tag `14.0.11@sha256:7b809052450067bb5c508600409db261d3d498971b77c8ecd647ccaf079323f3`
- Service port 80 (name not shown in grep)
- `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`
- Persistence mountPath `/shared/seafile`
- env via `env-secrets` secret reference

## Chart files
- Chart.yaml, values.yaml, values.schema.json, CHANGELOG.md, README.md, ci/, docs/, templates/
- Install: `oci://oci.trueforge.org/truecharts/seafile`; builds on common library chart; not upstream-maintained.

## Notes
- Chart pins 14.0.11, plan pins 14.0.9 (see README conflict).
