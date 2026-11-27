# TrueCharts chart: leaf2mqtt

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/leaf2mqtt/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "Nissan Leaf connected services to MQTT adapter". Chart 17.0.0, `appVersion 0.6.0`. Category media.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources: ghcr.io/k8s-at-home/leaf2mqtt, github.com/k8s-at-home/container-images, github.com/mitsumaui/leaf2mqtt, trueforge chart path.

## Image
- Repository `ghcr.io/k8s-at-home/leaf2mqtt` (upstream k8s-at-home registry, NOT a trueforge image)
- Tag `v0.6@sha256:aef098fe333c18f0efc31dca6256e2c0aa209befb6b339d948e62c0ee5877391`, pullPolicy IfNotPresent.

## Security
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Ports
- Service `main` disabled. No ports.

## Env vars (chart)
| Name | Value |
| --- | --- |
| LEAF_TYPE | "" (empty) |
| MQTT_HOST | "" (empty) |
| MQTT_PORT | 1883 |
| MQTT_BASE_TOPIC | leaf |
| UPDATE_INTERVAL_MINUTES | 60 |
| CHARGING_UPDATE_INTERVAL_MINUTES | 60 |
| LOG_LEVEL | Warning |
| LEAF_USERNAME | leafuser |
| LEAF_PASSWORD | secretKeyRef `env-secrets` key `LEAF_PASSWORD` |
| MQTT_USERNAME | mqttuser |
| MQTT_PASSWORD | secretKeyRef `env-secrets` key `MQTT_PASSWORD` |

- Chart secret `env-secrets` (enabled) with placeholder values `changeme` for LEAF_PASSWORD and MQTT_PASSWORD.

## Probes
- All disabled (liveness, readiness, startup).

## Persistence
- None in values.yaml.

## Gotchas
- Chart image is the k8s-at-home registry copy of leaf2mqtt v0.6.
- Chart `LEAF_USERNAME`/`MQTT_USERNAME` have example defaults (`leafuser`, `mqttuser`).
