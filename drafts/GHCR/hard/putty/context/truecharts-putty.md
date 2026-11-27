# TrueCharts chart: putty

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/putty/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `putty` v17.1.1, appVersion 26.11.2, train stable, category utilities.
- Dependency: `common` 32.8.5. kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/jlesage/putty`
- tag: `v26.11.2@sha256:f04c14dc...11838c` (pullPolicy IfNotPresent)

## Ports
| name | port | target | note |
| --- | --- | --- | --- |
| main | 10266 | 5800 | web GUI, http |
| vnc | 10267 | 5900 | VNC (enabled) |

## Env (chart)
- `configmap putty` (via envFrom): ENABLE_CJK_FONT, KEEP_APP_RUNNING, SECURE_CONNECTION, DISABLE_RESTART_SESSION_DIALOG_WINDOW (all 0/1 via ternary, default false), DISPLAY_WIDTH 1280, DISPLAY_HEIGHT 768.
- Secret env: `VNC_PASSWORD` from secret `env-secrets` (value "").

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |

## Probes
- liveness, readiness, startup: type tcp (no path).

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- container caps add: NET_BIND_SERVICE, KILL.

## Gotchas
- Chart defaults differ from upstream: upstream DISPLAY_WIDTH 1920 / HEIGHT 1080; chart 1280 x 768.
