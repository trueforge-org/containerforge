# TrueCharts standardnotes-web chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/standardnotes-web (values.yaml raw, fetched 2026-11-26).

## values.yaml facts
- Image: `docker.io/standardnotes/web`, tag `stable@sha256:bf99c33bad03ca9ccd79c40e6aece368a6c23b887f95fcfeeaab86f68f0e3878`, pullPolicy IfNotPresent
- `persistence: {}` (no persistence)
- `readOnlyRootFilesystem: false`; `runAsUser: 0`, `runAsGroup: 0`
- Service main and related ports are disabled (`enabled: false`); port numbers not shown by grep.
- Tag `stable` differs from upstream docs (`latest`).
