# TrueCharts: homebridge (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebridge/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `homebridge` version 15.0.0, appVersion 2026.11.15. Category media. "A lightweight NodeJS server that emulates the iOS HomeKit API".
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart sources: ghcr.io/homebridge/homebridge, github.com/oznu/docker-homebridge, homebridge.io.

## Image (values.yaml)
- repository: ghcr.io/homebridge/homebridge
- tag: `2026-11-15@sha256:f521cfbc8ff88bcf9d01d6a60a1127cf6aab972cb721eca1598a90f601190975`
- pullPolicy IfNotPresent.

## Env
| Name | Value |
| --- | --- |
| HOMEBRIDGE_CONFIG_UI | 1 |

## Ports
- service main: 8581 http (container 8581).

## Persistence
- config -> /homebridge (enabled).

## Security
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.

## Gotchas
- Image tag and appVersion both 2026-11-15, matching the source Dockerfile tag in urls.txt (aligned).
- Chart runs as root (image itself also sets USER=root).
