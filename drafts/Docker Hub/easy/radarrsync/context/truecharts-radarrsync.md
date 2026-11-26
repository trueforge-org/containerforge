# TrueCharts chart: radarrsync

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/radarrsync (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/radarrsync/values.yaml (fetched)

## Image
- repository `docker.io/dmanius/radarrsync-docker`, tag `latest@sha256:805e1578bea5719e2aedc6fca77013824a3024d641021e23fa5c37cd19a23322`, pullPolicy IfNotPresent.

## Ports
- Main service and port both `enabled: false`.

## Persistence
- `persistence: {}` (none).

## securityContext (container)
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Env vars
- PROFILE_ID "", RADARR_URL "", RADARR4K_URL "".
- RADARR_KEY and RADARR4K_KEY come from secret `env-secrets` (keys of the same name). The secret is enabled with empty values.

## Probes
- liveness, readiness and startup all disabled.
