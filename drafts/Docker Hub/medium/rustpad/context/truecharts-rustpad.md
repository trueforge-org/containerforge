# TrueCharts chart: rustpad

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rustpad/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `rustpad`, train stable, category Cloud. appVersion `latest`.
- Description: minimal self-hosted collaborative text editor (operational transformation); no database required.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1, min helm 3.14; max k8s 1.35.0.
- Chart `sources:` list: github ekzhang/rustpad, truecharts chart path, hub.docker.com/r/ekzhang/rustpad.

## Image (values.yaml)
- repository `docker.io/ekzhang/rustpad`, tag `latest@sha256:536b63883b2661f31de580df438427f2b799f9284bf9f908708ea3b5d231b585`, pullPolicy IfNotPresent.

## Persistence
- persistence.storagedatabase: enabled, mountPath `/persist`.

## Service / ports
- service.main.ports.main: port 3030, protocol tcp, targetPort 3030.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| EXPIRY_DAYS | "1" |
| RUST_LOG | info |
| SQLITE_URI | sqlite:///persist/rustpad_db.db |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart runs as root).

## Gotchas
- Chart points SQLite into `/persist`, not `/config`; ContainerForge plan uses `/config`, so the mount path differs from the chart.
