# TrueCharts chart: serpbear

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/serpbear/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `serpbear`. Chart version 9.0.0, appVersion `latest`.
- Description: Search Engine Position Tracking App.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. No other dependencies.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github towfiqi/serpbear, truecharts chart path, hub.docker.com/r/towfiqi/serpbear.

## Image (values.yaml)
- repository `docker.io/towfiqi/serpbear`, tag `latest@sha256:7a2e29bfe682082642be1e0fe0a0d7b561470427d25a4afd25eca1e7223b993b`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 10605 (service side), protocol http, targetPort 3000 (container).

## Persistence
- persistence.data: enabled, mountPath `/app/data` (upstream SQLite path).

## Chart-level config (`serpbear:` block)
| Key | Value |
| --- | --- |
| secret | "PLACEHOLDERSECRETKEYXXXXXXXXXXXX" (must be changed, >=32 chars, comment in chart) |
| api_key | "" |
| app_url | http://localhost:10605 |
| password | secret |
| session_duration | 24 |
| user | admin |

- Container env comes from `envFrom: secretRef serpbear-secret` (chart-generated secret built from the keys above; mapping of key names to env names is not in values.yaml).

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart runs as root; upstream runs as nextjs uid 1001).

## Gotchas
- Placeholder secret and default password `secret` in values: must be overridden.
- Chart uses service port 10605 mapped to container 3000 (not 1:1).
