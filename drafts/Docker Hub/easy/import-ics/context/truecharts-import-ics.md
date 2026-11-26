# TrueCharts chart: import-ics

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/import-ics (tree page; read via raw files below)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/import-ics/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/import-ics/values.yaml
- Fetched 2026-11-26

## What it is
Chart `import-ics` version `11.0.0` (`appVersion: latest`), type application. Description: "Runs a python script at a crontab defined interval that downloads/imports ics files into a caldav server." Category Productivity. Depends on `common` library chart `32.8.5` from `oci://oci.trueforge.org/truecharts`.

## Container
- Image: `docker.io/vilhjalmr26/import_ics`, tag `latest@sha256:9eb432e43e44d39d19b39ad277c47873ee615ae2f8ed06d033f3d99cc5e347b8`, pullPolicy `IfNotPresent`.

## Security context (values.yaml)
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.
- No `podSecurityContext` present.

## Env (values.yaml)
- `CRONTAB_SCHEDULE: 0 0 * * *`
- `ICS_URL: ""`
- `ICS_USERNAME: ""`
- `ICS_PASSWORD`: from secretKeyRef `env-secrets` key `ICS_PASSWORD`; secret `env-secrets` enabled with `ICS_PASSWORD: ""`.

## Persistence (values.yaml)
- `config`: enabled, mountPath `/config`.
- `icsexportfolder`: enabled, mountPath `/import_ics/ical_export`.

## Service / probes
- `service.main.enabled: false`, port `main` disabled. No probes enabled (liveness, readiness, startup all false).

## Gotchas
- Chart mounts the export folder at `/import_ics/ical_export` (upstream layout). The ContainerForge plan uses `/config/ical_export` instead (see plan section 9); this is a design difference, not a mistake in the plan.
- Chart `appVersion: latest` and image tag `latest`, pinned by digest.
- `ICS_PASSWORD` is a secret in the chart.
- Chart sources list: the Vilhjalmr26 repo, the TrueCharts chart path, and the Docker Hub page.
