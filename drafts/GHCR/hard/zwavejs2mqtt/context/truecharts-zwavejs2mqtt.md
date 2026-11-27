# TrueCharts zwavejs2mqtt (chart page)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zwavejs2mqtt/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zwavejs2mqtt/Chart.yaml
- Fetched 2026-11-27 (master)

## What it is
- Chart `zwavejs2mqtt` v27.0.0, appVersion 11.27.0. "Full featured Z-Wave Control Panel and MQTT Gateway, using NodeJS and Vue."
- Dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. kubeVersion `>=1.33.0-0`.
- Sources: ghcr.io/zwave-js/zwave-js-ui, github.com/zwave-js/zwave-js-ui.

## Image
- `ghcr.io/zwave-js/zwave-js-ui`, tag `11.27.0@sha256:0f3ad23ccf5ff2256ad8cc060ab0fc987b8f52a8427eac337f93b058fa628f35`, pullPolicy IfNotPresent.

## Ports
| Service | Port name | Port | targetPort | Notes |
| --- | --- | --- | --- | --- |
| main | main | 8091 | 8091 | web UI |
| ws | ws | 10046 | 3000 | websocket; container target 3000 (chart evidence for port 3000) |

Protocol not specified.

## Env
- None defined in chart values.

## Volumes
- `config`: enabled, mountPath `/usr/src/app/store` (chart path; ContainerForge image uses `/config/store`).

## Probes
- liveness and readiness enabled, custom specs commented out (commented example: httpGet /health, initial delay 30, period 10, timeout 10, failureThreshold 5).
- startup disabled.

## User/UID
- Container: readOnlyRootFilesystem false. runAsUser/runAsGroup not set.

## Host access
- No hostNetwork, privileged, or device settings.
