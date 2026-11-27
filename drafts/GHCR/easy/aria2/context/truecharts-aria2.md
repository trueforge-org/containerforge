# TrueCharts chart: aria2 (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/aria2/values.yaml , .../Chart.yaml

## What it is
- Chart `aria2` version 18.0.0, appVersion `latest`, dep `common` 32.8.5
- Description: "aria server for downloading web content"; category media
- Sources listed: https://ghcr.io/p3terx/aria2-pro , https://github.com/P3TERX/Aria2-Pro-Docker

## Image (values.yaml)
- repository `ghcr.io/p3terx/aria2-pro`
- tag `latest@sha256:086d1a37c586edb07ec0fb956bf9edd89d1d38d138ad5309ff96d510c8c9a011`

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Service / ports
| Name | Port | Protocol |
| --- | --- | --- |
| main | 6800 | http (RPC) |
| listen | 6888 | tcp (enabled) |

## Env (container `main`)
| Name | Chart value |
| --- | --- |
| RPC_PORT | {{ service.main.ports.main.port }} (6800) |
| LISTEN_PORT | {{ service.listen.ports.listen.port }} (6888) |
| DISK_CACHE | 64M |
| IPV6_MODE | false |
| UPDATE_TRACKERS | false |
| CUSTOM_TRACKER_URL | https://trackerslist.com/all_aria2.txt |
| RPC_SECRET | secretKeyRef env-secrets/RPC_SECRET (chart default "ChangemeNow") |

## Probes
- liveness, readiness, startup: all `type: tcp`

## Persistence
- `config` enabled, mountPath `/config`
- (no /downloads mount in chart values)

## Gotchas
- Chart sets UPDATE_TRACKERS false; upstream Dockerfile default is true
