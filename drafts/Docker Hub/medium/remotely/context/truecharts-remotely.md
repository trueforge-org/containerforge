# TrueCharts chart: remotely

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remotely/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remotely/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.0 |
| appVersion | latest |
| category | Tools-Utilities |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| description | A remote control and remote scripting solution, built with .NET 5, Blazor, SignalR Core, and WebRTC. |
| sources | github.com/trueforge-org/truecharts (chart); hub.docker.com/r/immybot/remotely; remotely.one |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/immybot/remotely |
| image.tag | latest@sha256:9bdff2d8f7a9926731fe8394d9b0292eb5679153b1da7f3b80ecd9fa9823b89b |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| service.main.ports.main | port 9280, protocol http, targetPort 8080 |
| persistence.data | enabled, mountPath `/app/AppData` |

## Ports
- Service 9280 -> container 8080. No ASPNETCORE_HTTP_PORTS set in chart values.

## Volumes/paths
- `/app/AppData` (SQLite DB and app data; the image's Remotely.db path per upstream compose is `/app/AppData/Remotely.db`).

## User/UID
- Chart runs as root (runAsUser 0). Image user not set in the fetched Dockerfile (no USER line).

## Env vars
- None set by chart values.

## Gotchas
- Chart pins `latest` digest 9bdff2d8...; Docker Hub `latest` last updated 2024-08-12.
- The chart's target port 8080 relies on the ASP.NET default when ASPNETCORE_HTTP_PORTS is unset (general .NET behaviour, not stated in fetched sources; not verified in a run).
