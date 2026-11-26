# TrueCharts chart: venstar2mqtt

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/venstar2mqtt (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## What it is
- TrueCharts Helm chart for the upstream bridge image. Used as reference for env, security context and persistence expectations.

## Image
- repository `docker.io/terafin/mqtt-venstar-bridge`, pullPolicy `IfNotPresent`, tag `latest@sha256:18cc80c8...` (truncated in fetch).

## Env vars (chart defaults)
| Name | Default | Notes |
| --- | --- | --- |
| `MQTT_HOST` | `""` | Must be filled in by user |
| `MQTT_USER` | `""` | Must be filled in by user |
| `MQTT_PASS` | from secret `env-secrets` key `MQTT_PASS` | Secret value empty placeholder |
| `TOPIC_PREFIX` | `venstar2mqtt` | |
| `VENSTAR_HOST` | `""` | Must be filled in by user |

## Ports
- Service and ports disabled (`service.main.enabled: false`, `ports.main.enabled: false`). No listening port.

## Volumes/paths and persistent data
- `persistence: {}`. No volumes.

## User/UID & permissions
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. `privileged` not set.

## Healthcheck/readiness endpoints
- liveness, readiness and startup probes all disabled.

## Gotchas
- The chart runs the bridge as root with a writable root filesystem. plan.md's non-root, read-only plan is not contradicted by the chart; the chart simply does not set it.
- `TOPIC_PREFIX` default in the chart is `venstar2mqtt`, which differs from the `/venstar` default planned in plan.md section 7 (plan.md chooses its own default; not an error, but it differs from the chart).
