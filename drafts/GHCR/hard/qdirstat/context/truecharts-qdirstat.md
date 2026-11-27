# TrueCharts chart: qdirstat

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qdirstat/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `qdirstat` v-chart version from Chart.yaml (appVersion 26.11.3), train stable, category media.
- Description: graphical disk space usage viewer and cleanup tool.
- Dependency: `common` 32.8.5. kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/jlesage/qdirstat`
- tag: `v26.11.3@sha256:117a58b7...c9524` (pullPolicy IfNotPresent)

## Ports
| name | port | target | note |
| --- | --- | --- | --- |
| main | 10262 | 5800 | web GUI (http) |
| vnc | 10263 | 5900 | VNC (enabled) |

## Env (chart)
- `configmap qdirstat` (envFrom): ENABLE_CJK_FONT (false), KEEP_APP_RUNNING (false), SECURE_CONNECTION (false), DISPLAY_WIDTH 1280, DISPLAY_HEIGHT 768.
- Secret env: `VNC_PASSWORD` from `env-secrets` (value "").

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |
| storage | /storage |

## Probes
- liveness, readiness, startup: type tcp.

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- container caps add: NET_BIND_SERVICE, KILL.

## Gotchas
- Chart DISPLAY 1280x768; upstream README default 1920x1080.
- Chart sets no QDIRSTAT_STARTUP_SCAN_FOLDER (upstream image ENV, empty).
