# TrueCharts chart: dropbox-by-otherguy

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dropbox-by-otherguy (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dropbox-by-otherguy/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/otherguy/dropbox`, tag `latest@sha256:2ed2f984344974e4b97fa88ee2bd8ce23136e49953b6680399ea23e426b18365`, pullPolicy IfNotPresent. (Chart tracks `latest`, no version pin.)

## Service
- `service.main` disabled, port `main` disabled. No port number.

## Persistence (no type)
- `dropboxsettings`: mountPath `/opt/dropbox/.dropbox`, enabled.
- `dropboxuserfiles`: mountPath `/opt/dropbox/Dropbox`, enabled.

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false. privileged, allowPrivilegeEscalation, fsGroup, podSecurityContext not specified.

## Env vars
- DROPBOX_GID "100", DROPBOX_UID "99".

## Probes
- liveness, readiness, startup all disabled.
