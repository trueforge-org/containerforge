# TrueCharts: haste-server chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/haste-server (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/haste-server/values.yaml)
**Fetched:** 2026-11-26

## Image
- `ghcr.io/k8s-at-home/haste-server`, tag `latest@sha256:827aa2f2389d94a522e333080fa8cbc0e0a487c5681173caca785b3b6b9e5b01`, IfNotPresent. The chart still uses the k8s-at-home image (see README for that repo's status).

## Service
- `main`, port `main`: port 7777, target port 7777.

## Env
- `STORAGE_FILEPATH=/config`
- `STORAGE_TYPE=file`

## Persistence
- `config` volume enabled, mounted at `/config`. No size, no readOnly.

## Security context / probes
- None specified (no runAsUser, runAsGroup, readOnlyRootFilesystem). No probes.

## Other
- Schema reference `./values.schema.json`.
- Workload under `workload.main.podSpec.containers.main`.
- Note: the chart stores paste data in `/config` (not `/app/data`); the plan's `/config/data` is consistent with that intent.
