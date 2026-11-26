# TrueCharts: maintainerr chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/maintainerr (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maintainerr/values.yaml)
**Fetched:** 2026-11-26

## Image
- `ghcr.io/maintainerr/maintainerr:3.33.0`, digest `sha256:124b53cfec9c17dae03a69243b0a2e7b6de740150112b5210b784ce8fa0a2852`, IfNotPresent.
- **Note:** the draft and plan.md state the chart pins 3.32.0. At this fetch the chart pins 3.33.0.

## Service
- `main`, protocol http, port 6246, target port 6246.

## Env
None defined.

## Persistence
- Volume `data`: enabled, mounted at `/opt/data`. No readOnly, size or PVC name.

## Security context
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Container runs as root with writable rootfs. (Plan.md's draft expectations agree.)

## Probes
None defined.

## Other
- Schema reference `./values.schema.json`.
