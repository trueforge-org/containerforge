# TrueCharts chart: openbooks (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openbooks/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openbooks/Chart.yaml (2026-11-27)

What it is: "IRC Highway eBook Downloads." Chart `version: 10.0.0`, `appVersion: 4.5.0`. Category media. Depends on `common` 32.8.5.

Image (values.yaml):
- repository `ghcr.io/evan-buss/openbooks`
- tag `4.5.0@sha256:3f2e59a75b68950d57cfec5dc2b1b31d6c6b02706097c70b5438499b59fbdea2`
- pullPolicy IfNotPresent

Chart-set app options (values `openbooks:` block, rendered as flags):
| Key | Value |
| --- | --- |
| user_name | `truecharts` |
| server | `irc.irchighway.net:6697` |
| debug | true |
| log | true |
| search | `search` |
| persist | false |
| no_browser_downloads | false |
| tls | true |

Ports: service `main`, protocol http, port 10608 (targetPort not set in values).

Volumes/paths:
| Persistence | mountPath |
| --- | --- |
| books | `/books/books` |
| logs | `/books/logs` |

Note: upstream image declares `VOLUME ["/books"]` and uses `/books` as the server dir. The chart's mount paths sit under `/books`.

Probes: liveness, readiness, startup all `type: http`, `path: "/"`.

Security: `readOnlyRootFilesystem: false`. No runAsUser set in values.

Gotchas:
- Chart's `log: true` and `debug: true` are set by default.
- Chart mount `/books/logs` implies a log dir the app must write to.
