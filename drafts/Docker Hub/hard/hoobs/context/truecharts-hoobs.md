# TrueCharts hoobs chart (reference only)

Source URLs:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hoobs/values.yaml (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hoobs (not fetched; values.yaml read instead)

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/hoobs/hoobs |
| tag | latest@sha256:c9b84d76659409cbc5910dd39c8bcb5ba2a338dacc7068f6941d06e82445d6ab |
| pullPolicy | IfNotPresent |

## Ports
| Name | Port | Target | Notes |
| --- | --- | --- | --- |
| homebridgeport | 51826 tcp | 51826 | HAP (enabled) |
| main | 8082 http | 80 | web UI |

## Persistence
- applicationpath: mountPath `/hoobs`

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0. No podSecurityContext. No env block.

## Gotchas
- Chart runs as root with writable rootfs.
- Chart pins `latest` plus digest.
