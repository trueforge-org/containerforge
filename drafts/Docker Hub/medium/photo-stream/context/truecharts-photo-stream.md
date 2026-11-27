# TrueCharts chart: photo-stream

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photo-stream/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photo-stream/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `photo-stream`, chart version 11.0.0, appVersion `latest`.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/waschinski/photo-stream |
| tag | latest@sha256:fa30eb2631cd15bda74cb3157177252e51539dec29c824f1c3ce0fd79d8e09ec |
| pullPolicy | IfNotPresent |

## Ports
| Service | Protocol | Port | Target |
| --- | --- | --- | --- |
| main | http | 4000 | 4000 |

## Env vars (main container)
| Name | Value |
| --- | --- |
| AUTHOR_NAME | TrueCharts |
| DESCRIPTION | TrueCharts Photo Stream collection. |
| SHOW_OFFICIAL_GITHUB | "0" |
| TITLE | Photo Stream for TrueCharts |

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| storageimages | /photo-stream/photos/original |

## User/UID
- Container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root; appVersion `latest` is unpinned, image pinned by digest only.
- Chart mounts photos into `/photo-stream/photos/original` (upstream app path).
