# TrueCharts chart: quake3 (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quake3/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `quake3` v11.0.0, appVersion `latest`, category GameServers, depends on `common` 32.8.5.
- Description: downloads and installs Quake III server; user must copy .pk3 files from their game directory.
- Sources: https://ghcr.io/ich777/quake3 , https://www.idsoftware.com/

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/ich777/quake3 |
| tag | latest@sha256:921d9f076b2f8e7f2eea0b947ddc7949013480b8f0a088b1333dc5603d2f28a3 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 27960 | 27960 | udp |

(The chart declares UDP. The upstream Dockerfile declares no EXPOSE.)

## Persistence
- `serverfiles`: enabled, mountPath `/quake3`

## Container env (chart override)
| Name | Value |
| --- | --- |
| DL_URL_PATCH | https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/quake3-1.32c.zip |
| DL_URL_PR | https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3apoint-1.32b-3.x86.run |
| GAME_PARAMS | +set sv_punkbuster 0 +set fs_game osp +set com_hunkMegs 32 |
| Q3_MAP | q3dm1 |
| Q3_PORT | "27960" |

## Probes
- liveness, readiness, startup: all disabled.

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
