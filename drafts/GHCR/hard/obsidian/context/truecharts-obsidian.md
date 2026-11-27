# TrueCharts chart: obsidian

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/obsidian/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `obsidian` v12.0.0, appVersion 0.1.1, category productivity.
- Image is the third-party sytone/obsidian-remote image, not Obsidian itself.

## Image
- repository: `ghcr.io/sytone/obsidian-remote`
- tag: `0.1.1@sha256:0494ea57446e77609a469caf08a6886f3825f893883bfab2f4736e06d01c19b2`
- pullPolicy: IfNotPresent

## Service / ports
| Name | Port | Target | Protocol / notes |
| --- | --- | --- | --- |
| main | 10292 | 8080 | http (web UI) |
| api.http | 27123 | 27123 | enabled |
| api.https | 27124 | 27124 | enabled |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config/.config/obsidian |
| vaults | /vaults |

## Security
- readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart config mount is `/config/.config/obsidian` (not `/config`).
- Chart pins sytone image 0.1.1; the image runs Obsidian 0.15.9 (see sytone Dockerfile file).
