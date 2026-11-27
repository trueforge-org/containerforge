# TrueCharts chart: dell-idrac-fan-controller

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dell-idrac-fan-controller/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dell-idrac-fan-controller/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `dell-idrac-fan-controller` version 11.0.0, appVersion `latest`, train stable.
- Description: control Dell PowerEdge fans via IPMI.
- Chart sources: `https://ghcr.io/tigerblue77/dell_idrac_fan_controller`, upstream GitHub repo.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/tigerblue77/dell_idrac_fan_controller` (GHCR) |
| tag | `latest@sha256:c5826605d1dae111a9ef3aa4d76e2f038da8906026ee7dfb3bb0e1fbd237d276` |
| pullPolicy | IfNotPresent |

## Env (workload.main.podSpec.containers.main.env)
| Name | Chart value |
| --- | --- |
| IDRAC_HOST | "" |
| IDRAC_USERNAME | "" |
| IDRAC_PASSWORD | secretKeyRef `env-secrets`/`IDRAC_PASSWORD` |
| FAN_SPEED | 5 |
| CPU_TEMPERATURE_THRESHOLD | 50 |
| CHECK_INTERVAL | 60 |
| DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE | false |

Upstream Dockerfile defaults differ: `IDRAC_HOST=local`, `CPU_TEMPERATURE_THRESHOLD=auto`, `CHECK_INTERVAL=5`. Chart overrides all three.

## Ports
- service.main `enabled: false`. No port exposed. Container is a headless daemon.

## Volumes
- None configured in chart.

## Probes
- liveness, readiness, startup all `enabled: false`. Chart does not use the image HEALTHCHECK.

## Secret
- `env-secrets` (enabled) with key `IDRAC_PASSWORD` (empty default).

## Gotchas
- Chart pins no version; `appVersion: latest` with a digest.
- `IDRAC_HOST` and `IDRAC_USERNAME` are empty by default, so the container needs user input to run.
- The iDRAC account must be an Administrator (upstream README).
