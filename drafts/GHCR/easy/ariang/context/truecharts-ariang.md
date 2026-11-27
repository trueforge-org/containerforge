# TrueCharts chart: ariang (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ariang/values.yaml , .../Chart.yaml

## What it is
- Chart `ariang` version 14.0.0, appVersion 1.3.13, dep `common` 32.8.5
- Description: "A modern web frontend making aria2 easier to use | Aria2 WebUI."
- Category media; sources: https://ghcr.io/leonismoe/ariang , https://github.com/leonismoe/docker-images

## Image (values.yaml)
- repository `ghcr.io/leonismoe/ariang`
- tag `1.3.13@sha256:eb9abf28d706026ce82075fc126b900badf401d95db5c0ed1971db92df56be03`

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, allowPrivilegeEscalation true, runAsUser 0, runAsGroup 0
- capabilities add: SYS_CHROOT

## Service / ports
| Name | Port | targetPort | Protocol |
| --- | --- | --- | --- |
| main | 10276 | 8080 | http |

## Env
- `env: {}` (none set)

## Probes
- liveness, readiness, startup: `type: http`, path `/`

## Gotchas
- Chart pins 1.3.13; upstream release tag is 1.3.15 (see mayswind file)
- Chart runs as root with SYS_CHROOT (upstream image drops to nobody via darkhttpd --uid)
