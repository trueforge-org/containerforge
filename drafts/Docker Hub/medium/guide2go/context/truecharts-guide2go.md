# TrueCharts chart: guide2go
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guide2go (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 11.0.0, appVersion latest
- dependency: common 32.8.5; train stable; min helm 3.14, max helm 4.1

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/alturismo/guide2go |
| image.tag | latest@sha256:e67eb2661e3ee27dfdc160ba063330df34a9b8d56e2f2cf1d7e9f83c36caf2d9 |
| persistence.config | enabled, mountPath /config |
| persistence.guide2go | enabled, mountPath /guide2go |
| persistence.tvh | enabled, mountPath /TVH |
| securityContext.container | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false |
| service.main | enabled false (no port exposed by chart) |
| probes (liveness, readiness, startup) | all disabled |

## Notes
- No env vars set in values (TZ comes from image default Europe/Berlin).
- Chart runs as root.
