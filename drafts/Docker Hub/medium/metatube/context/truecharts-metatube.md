# TrueCharts chart: metatube

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metatube/values.yaml, .../Chart.yaml (fetched 2026-11-26)

## What it is
- Chart `metatube`, version 11.0.0, appVersion "latest"
- Description: downloads video from YouTube and adds metadata from a metadata provider
- Depends on `common` 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- Repository: docker.io/jvt038/metatube
- Tag: latest@sha256:30591e0b8b498286d8c0e8bdc41c0ebeaaf30be0edd8a9a00a44ddde7a9fdd59
- pullPolicy: IfNotPresent

## Ports
- Service main: port 5000 tcp -> targetPort 5000

## Env vars
| Name | Value |
| --- | --- |
| DEBUG | "False" |
| LOG | "False" |
| LOG_LEVEL | "10" |
| SOCKET_LOG | "False" |

## Volumes/paths
| Name | Enabled | mountPath |
| --- | --- | --- |
| storagedatabase | true | /database |
| storagedownloads | true | /downloads |

## Probes
- None set in values.yaml

## Security
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0; fsGroup not set

## Gotchas
- Chart runs as root with writable rootfs.
