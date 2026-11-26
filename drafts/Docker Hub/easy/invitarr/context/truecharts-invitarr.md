# TrueCharts chart: invitarr

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/invitarr (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/invitarr/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/invitarr/values.yaml
- Fetched 2026-11-26

## What it is
Chart `invitarr` version `11.0.0`, `appVersion: latest`. Description: "A chatbot that invites discord users to plex." Category home-automation. Depends on `common` `32.8.5` from `oci://oci.trueforge.org/truecharts`.

## Container
- `docker.io/piratify/invitarr`, tag `latest@sha256:78a82851aa167e89a5f5d6f025d81ad8b4c08856f166a92f960e4a57a9c264d9`, pullPolicy `IfNotPresent`.

## Security context
- container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No podSecurityContext.

## Env
- `token` from secretKeyRef `env-secrets` key `token`; secret `env-secrets` enabled with `token: ""`.

## Persistence
- `config`: enabled, mountPath `/app/app/config`.

## Service / probes
- service.main disabled, port main disabled. All probes (liveness, readiness, startup) disabled.

## Gotchas
- Chart state path is `/app/app/config` (upstream layout), while plan moves state under `/config` (cwd). Design difference; existing data needs moving (plan section 9).
