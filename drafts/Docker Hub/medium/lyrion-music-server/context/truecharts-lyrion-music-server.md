# TrueCharts: lyrion-music-server (stable)

Source URL(s), fetched 2026-11-27:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lyrion-music-server/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lyrion-music-server/Chart.yaml

## What it is
- Chart `lyrion-music-server`, chart version 8.0.1, appVersion 9.2.0, type application, apiVersion v2
- Description: "Lyrion Music Server is a platform for home/office audio streaming."
- Keywords: lyrion-music-server, logitech-media-server, squeezebox, audio, streaming
- Category: media; train: stable; deprecated: false
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts
- kubeVersion >=1.33.0-0; min helm 3.14, max helm 4.1; max kubernetes 1.35.0

## Image (values.yaml)
- Repository: `docker.io/lmscommunity/lyrionmusicserver`
- Tag: `9.2.0`
- Digest: `sha256:91bf3760e936cdcce48b19310b132e82d58fa4a91149e098b20163bc6633b68a`
- pullPolicy: IfNotPresent

## Ports (values.yaml)
| Service | Port name | Port | targetPort | Protocol | Enabled |
| --- | --- | --- | --- | --- | --- |
| main | main | 9000 | not set | default | default |
| cli | cli | 9090 | 9090 | default | true |
| playertcp | slimprototcp | 3483 | 3483 | default | true |
| playerudp | slimprotoudp | 3483 | 3483 | udp | true |

## Env vars (values.yaml)
| Name | Value |
| --- | --- |
| HTTP_PORT | `{{ .Values.service.main.ports.main.port }}` = 9000 (container `main`) |

## Volumes (values.yaml)
| Name | Enabled | Mount path |
| --- | --- | --- |
| config | true | `/config` |

## Probes
- None defined.

## securityContext (container, values.yaml)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, fsGroup not set

## Command / args overrides
- None.

## Gotchas
- Chart runs as root (UID/GID 0) with non-readonly rootfs. This is a TrueCharts default, not an upstream requirement; the image itself is controlled by PUID/PGID env (see upstream summary).
- Chart.yaml has no image or version annotations.
