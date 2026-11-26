# TrueCharts chart: iyuuplus
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/iyuuplus (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 15.0.0, appVersion latest; common 32.8.5; min helm 3.14, max helm 4.1

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/iyuucn/iyuuplus |
| image.tag | latest@sha256:9bcdb525a8fb4d7d4ca8eb29ad4d22e95083f8171c9bcf4e8001a1148d621dc2 |
| service.main.ports.main | port 10188 -> targetPort 8787 |
| persistence.config | mountPath /IYUU/db |
| persistence.torrents | mountPath /torrents |
| persistence.btbackup | mountPath /BT_backup |
| securityContext.container | runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false |

## Notes
- No env vars or probes set in chart values.
- Chart targetPort 8787 is the PHP (webman) backend; upstream nginx listens 8780 and proxies to 8787 (see github-ledccn-iyuuplus-nginx.md).
- Chart mount paths (/IYUU/db, /torrents, /BT_backup) do not match upstream image volumes (/iyuu, /data).
