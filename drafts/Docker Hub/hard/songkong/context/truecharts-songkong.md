# TrueCharts songkong chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/songkong (values.yaml raw fetched 2026-11-26; tree page not separately fetched).

## values.yaml facts
- Image: `docker.io/songkong/songkong`, tag `latest@sha256:e13f264df79b1b880200b405b5efd395faeabe50c856341c12b13c2e5614cdc6`, pullPolicy IfNotPresent
- `readOnlyRootFilesystem: false`; `runAsUser: 0`, `runAsGroup: 0`
- Service port 4567 (tcp), targetPort 4567
- Persistence: `/music` and `/songkong` (mountPath, both enabled)
