# TrueCharts chart: imgpush
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/imgpush (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 11.0.0, appVersion latest; common 32.8.5; train stable

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/hauxir/imgpush |
| image.tag | latest@sha256:46bf9c2b4fd3be05c3d3470e0dd480399fb69a1e9631a095e25edd3de655c962 |
| service.main.ports.main | port 5000 -> targetPort 5000 (tcp) |
| persistence.storagecache | enabled, mountPath /cache |
| persistence.storageimages | enabled, mountPath /images |
| securityContext.container | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false |

## Notes
- No env vars set by chart; no probes overridden (default probes apply).
- Upstream image defaults: /images and /cache mkdir'd in the Dockerfile (see github-hauxir-imgpush-dockerfile.md).
- Upstream liveness endpoint: /liveness (README).
