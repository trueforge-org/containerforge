# TrueCharts chart: reubah (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/reubah/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `reubah` v5.0.0, appVersion `main`, category media, depends on `common` 32.8.5.
- Description: web-based tool for processing images and converting documents.
- Sources: https://ghcr.io/dendianugerah/reubah , https://github.com/dendianugerah/reubah

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/dendianugerah/reubah |
| tag | main@sha256:2db201bb197110681012b9721a6b92a502f3fc46f79e3f1d5cad1b6367dfcda1 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | protocol |
| --- | --- | --- |
| main | 8081 | http |

## Container env (chart override)
| Name | Value |
| --- | --- |
| PORT | "{{ .Values.service.main.ports.main.port }}" (renders 8081) |

## Persistence
- `app`: emptyDir, mountPath `/app/tmp`
- `tmp`: emptyDir, mountPath `/tmp`

## Notes
- No probes or security-context overrides in values.yaml.
