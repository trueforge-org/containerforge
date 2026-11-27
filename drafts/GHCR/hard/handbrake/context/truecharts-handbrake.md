# TrueCharts: handbrake (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/handbrake/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `handbrake` version 29.1.1, appVersion 26.11.2. Category media. "HandBrake is a tool for converting video..."
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.

## Image (values.yaml)
- repository: ghcr.io/jlesage/handbrake
- tag: `v26.11.2@sha256:354938c2f90b01bf021ae2a9802e634948b7cb9265de1700653ada95a65174c1`
- pullPolicy IfNotPresent.

## Env (via configmap `handbrake` envFrom, from values `handbrake.*`)
| Name | Default in chart |
| --- | --- |
| KEEP_APP_RUNNING | 0 (false) |
| DISPLAY_WIDTH | 1280 |
| DISPLAY_HEIGHT | 768 |
| SECURE_CONNECTION | 0 |
| ENABLE_CJK_FONT | 0 |
| AUTOMATED_CONVERSION_PRESET | "General/Very Fast 1080p30" |
| AUTOMATED_CONVERSION_FORMAT | mp4 |
| AUTOMATED_CONVERSION_KEEP_SOURCE | 1 (true) |
| AUTOMATED_CONVERSION_NON_VIDEO_FILE_ACTION | ignore |
| DARK_MODE | 0 |
| VNC_PASSWORD | secretKeyRef env-secrets/VNC_PASSWORD (chart default "") |

## Ports (service)
| Name | Service port | Target |
| --- | --- | --- |
| main (web GUI) | 10053 | 5800 |
| vnc | 10055 | 5900 |

## Probes
- liveness, readiness, startup: all type tcp (on container main).

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| storage | /storage |
| output | /output |
| varrun | disabled |

## Security
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.
- Container capabilities added: NET_BIND_SERVICE, KILL.

## Gotchas
- Chart runs as root with extra caps. VNC password is a secret.
- Chart appVersion 26.11.2 vs upstream Dockerfile URL in urls.txt pinned to v26.09.1 (see github-jlesage-docker-handbrake.md).
