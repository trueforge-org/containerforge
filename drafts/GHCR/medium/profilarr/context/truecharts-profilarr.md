# TrueCharts chart: profilarr (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/profilarr/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/profilarr/Chart.yaml (2026-11-27)

What it is: "Configuration management tool for Radarr/Sonarr that automates importing and version control of custom formats and quality profiles." Chart `version: 6.0.0`, `appVersion: 2.3.1`. Category Tools-Utilities.

Image (values.yaml):
- repository `ghcr.io/dictionarry-hub/profilarr`
- tag `2.3.1@sha256:352e42dec74ecfd68d13bb198fbc6d9346e3a8c55003026e1814e59319a2176d`
- pullPolicy IfNotPresent

Ports: service main, protocol http, port 6868.

Env vars (workload main):
| Name | Value |
| --- | --- |
| PORT | `{{ service.main.ports.main.port }}` (6868) |
| HOST | `0.0.0.0` |
| AUTH | `"on"` (on, oidc, off; on is default) |
| ORIGIN | `{{ chartContext.appUrl }}` (auto) |
Commented out: OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_DISCOVERY_URL.

Volumes/paths: persistence `config`, enabled, mountPath `/config`.

User/UID: `securityContext.container` runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false. The image's entrypoint drops to PUID/PGID (default 1000) when started as root.

Probes: none set in values. Upstream HEALTHCHECK: `curl -sf http://localhost:${PORT}/api/v1/health`.

Gotchas:
- Chart sets AUTH "on" explicitly; README says `oidc` is a deprecated alias.
- ORIGIN must be the public URL when behind a reverse proxy or OIDC is used.
