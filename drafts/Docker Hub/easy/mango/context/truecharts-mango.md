# TrueCharts chart: mango

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mango (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mango/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mango/values.yaml
- Fetched 2026-11-26

## What it is
Chart `mango` version `11.0.0`, `appVersion: latest`, not deprecated. Description: "Mango is a self-hosted manga server and reader." Category MediaApp-Books. Depends on `common` `32.8.5`. Kubernetes `>=1.33.0-0`.

## Container
- `docker.io/hkalexling/mango`, tag `latest@sha256:14b5e1dd467f5a2736cf6847f3be193a522c5fdd36d61b797652a2d513776911`, pullPolicy `IfNotPresent`.

## Security context
- container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No podSecurityContext.

## Env
- Not present.

## Persistence
- `config` enabled, mountPath `/root/.config/mango`.
- `data` enabled, mountPath `/root/mango`.

## Service / ports
- `main` port `9000`, protocol tcp, targetPort `9000`.

## Probes
- Not present.

## Gotchas
- Chart stores everything under `/root` (upstream layout). Plan moves state to `/config` (via `CONFIG_PATH` and env path overrides) and library to `/data`. Design difference; existing data must be migrated (plan section 9).
