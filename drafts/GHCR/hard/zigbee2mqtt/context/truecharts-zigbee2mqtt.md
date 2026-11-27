# TrueCharts zigbee2mqtt (chart page)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zigbee2mqtt/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zigbee2mqtt/Chart.yaml
- Fetched 2026-11-27 (master branch)

## What it is
- Chart `zigbee2mqtt` v18.0.0, appVersion 2.14.3. "Bridges events and allows you to control your Zigbee devices via MQTT".
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`.
- Sources listed: ghcr.io/koenkk/zigbee2mqtt, github.com/Koenkk/zigbee2mqtt.

## Image
- Repository `ghcr.io/koenkk/zigbee2mqtt`, tag `2.14.3@sha256:fb4a6b0f6868ad1cd6a9996479802b2420e599c3463b62bbff8c8cd9a908f43a`
- pullPolicy IfNotPresent

## Ports
| Name | Service port | targetPort | Notes |
| --- | --- | --- | --- |
| main | 10103 | not set | Chart port; frontend env is templated from this value |

## Env (main container)
| Var | Value |
| --- | --- |
| ZIGBEE2MQTT_DATA | `/data` |
| ZIGBEE2MQTT_CONFIG_FRONTEND_PORT | templated from service port `main` |
| USE_CUSTOM_CONFIG_FILE | `false` |
| ZIGBEE2MQTT_CONFIG_MQTT_USER | `""` |
| ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD | secretKeyRef `env-secrets` / `ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD` |

Commented out (not set): PERMIT_JOIN=false, MQTT_SERVER=mqtt://localhost, MQTT_BASE_TOPIC=zigbee2mqtt, SERIAL_PORT=/dev/ttyUSB0, SERIAL_ADAPTER=auto.

## Init container `init-config` (enabled)
- Type init, imageSelector image, `/bin/sh -c` script.
- Generates `/data/configuration.yaml` if absent and custom config not selected.
- Env: FRONTEND_PORT, PERMIT_JOIN, MQTT_SERVER, MQTT_BASE_TOPIC, SERIAL_PORT, SERIAL_ADAPTER, USE_CUSTOM_CONFIG_FILE (templated), MQTT_USER (from secret), MQTT_PASSWORD (secretKeyRef).

## Secret
- `env-secrets` enabled, key ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD (empty default).

## Volumes
- `data`: enabled, mountPath `/data`, targetSelectAll true. No type/size set.

## Probes
- None defined.

## User/UID
- Container securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- No fsGroup / podSecurityContext set.

## Host access
- No hostNetwork, privileged or device settings. Serial port appears only as a commented env example.

## Gotchas
- Chart maps config to `/data`; the ContainerForge image uses `/config` (see plan.md). Chart's service port 10103 differs from upstream frontend default 8080.
