# TrueCharts chart: sd-webui

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sd-webui/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sd-webui/values.yaml (fetched 2026-11-27)

## What it is
- Chart `sd-webui-docker` v7.0.0 (directory charts/stable/sd-webui), appVersion `latest`. Category MachineLearning.
- "sd-webui-docker Chart". Keywords Whisper, AI, ML.
- Sources: ghcr.io/neggles/sd-webui-docker, github ahmetoner/sd-webui-docker.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Images (values.yaml)
| variant | repository | tag | pullPolicy |
| --- | --- | --- | --- |
| main (imageSelector image) | ghcr.io/neggles/sd-webui-docker | latest@sha256:1795fe79...e53 | Always |
| vladImage | ghcr.io/neggles/sd-webui-docker | vlad@sha256:5fa3b1a9...a93 | Always |

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 7860 | 7860 |

## Args / env (container main)
- args: `--skip-version-check`
- env: PYTHONUNBUFFERED=1, SD_WEBUI_VARIANT=general

## Probes
- liveness, readiness, startup: enabled (no path set in chart)

## Persistence
| name | mountPath | enabled |
| --- | --- | --- |
| data | /data | true |
| output | /output | true |
| varrun | (none) | false |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Gotchas
- Chart appVersion is `latest` and image tags are floating `latest` / `vlad` digests.
- Chart expects /data and /output paths; image default DATA_DIR=/data.
