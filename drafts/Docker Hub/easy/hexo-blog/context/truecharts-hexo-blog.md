# TrueCharts chart: hexo-blog

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hexo-blog (chart dir); values read from https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hexo-blog/values.yaml · fetched 2026-11-26

## What it is
TrueCharts Helm chart for the hexo blog, using the community image `docker.io/fletchto99/hexo-dev-blog`.

## Container settings in the chart
- Image repository: `docker.io/fletchto99/hexo-dev-blog`
- Tag: `latest@sha256:099e3fd589b380ed72d5dedcdcf65bab6f2980d20f2aad397bb002c4e2f5aa3f` (pullPolicy `IfNotPresent`)
- runAsUser / runAsGroup: both `0` (container runs as root)
- readOnlyRootFilesystem: `false`
- privileged: not set in the values file (common default applies)

## Env vars (table)
| Name | Value in chart |
| --- | --- |
| HEXO_PLUGINS | `""` (empty) |

## Ports
- Service port `10306` (http) forwarding to targetPort `8080`.

## Volumes/paths and persistent data
- One persistence entry `config`, enabled, mounted at `/config`.

## Gotchas
- Chart runs as root with a writable rootfs; ContainerForge plan intends UID 568 and read-only rootfs instead (see plan.md section 9).
- Chart confirms container port 8080, which contradicts the draft's inferred port 4000 (agrees with plan.md, which uses 8080).
