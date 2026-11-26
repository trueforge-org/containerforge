# TrueCharts grafana-image-renderer chart (reference only)

Source URLs:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/grafana-image-renderer/values.yaml (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/grafana-image-renderer (not fetched; values.yaml read instead)

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/grafana/grafana-image-renderer |
| tag | latest@sha256:7ec15ea713a82d0cc16aaf1575b5416a6f8b178f475f4d1685e3322a5ce3fae3 |
| pullPolicy | IfNotPresent |

## Service
- service.main.enabled: false, ports.main.enabled: false (no service exposed by chart values)

## Persistence
- `persistence: {}` (none)

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart pins `latest` plus digest, not a version. Not a model for a rootless build.
- Chart runs as root with writable rootfs; upstream Dockerfile runs as 65532.
