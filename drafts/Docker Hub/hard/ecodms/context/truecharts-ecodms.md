# TrueCharts chart: ecodms

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ecodms (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ecodms/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/ecodms/allinone-18.09`, tag `latest@sha256:3530bbaf5001943acc47b888b78a41e78386368ca2c2738ab6fdc25b8a8bb206`, pullPolicy IfNotPresent. (The chart uses the 18.09 image, not a vendor 26.x build.)

## Service
- `service.main` disabled; port `main` disabled. No port number.

## Persistence (no type; all enabled)
- `backuppath` -> `/srv/backup`; `data` -> `/srv/data`; `restorepath` -> `/srv/restore`; `scaninputpath` -> `/srv/scaninput`.

## Security context
- runAsUser 0; runAsGroup 0; readOnlyRootFilesystem false. privileged, allowPrivilegeEscalation, fsGroup, podSecurityContext not set.

## Env vars
- None.

## Probes
- liveness, readiness, startup: all disabled.
