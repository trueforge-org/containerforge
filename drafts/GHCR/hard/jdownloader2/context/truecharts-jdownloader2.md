# TrueCharts jdownloader2 (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/jdownloader2/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `jdownloader2` v24.1.1, appVersion 26.11.2
- Description: download management tool (JDownloader)
- Deps: common, jdownloader, download (TrueCharts)
- Sources: ghcr.io/jlesage/jdownloader-2, github.com/jlesage/docker-jdownloader-2

## Image
- repository ghcr.io/jlesage/jdownloader-2, tag v26.11.2 (digest pinned), pullPolicy IfNotPresent

## Env vars (chart, via configmap `jdownloader` + secret)
| Var | Default | Notes |
| --- | --- | --- |
| KEEP_APP_RUNNING | false -> "0" | |
| DISPLAY_WIDTH | 1280 | |
| DISPLAY_HEIGHT | 768 | |
| SECURE_CONNECTION | false -> "0" | |
| ENABLE_CJK_FONT | false -> "0" | |
| VNC_PASSWORD | "" | from secret env-secrets |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10054 | 5800 (web GUI) |
| myjd | 3129 | 3129 (MyJDownloader direct connection) |
| vnc | 10056 | 5900 |

## Volumes/paths
- config -> /config (persistent), output -> /output (persistent), varrun disabled

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- capabilities add: NET_BIND_SERVICE, KILL

## Healthcheck
- tcp probes (liveness, readiness, startup)

## Gotchas
- Chart runs as root with extra caps.
- Homepage widget type jdownloader.
