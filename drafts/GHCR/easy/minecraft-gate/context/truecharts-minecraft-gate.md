# TrueCharts minecraft-gate chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-gate/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-gate/Chart.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `minecraft-gate` v5.0.0 (appVersion `latest`). Runs Gate (minekube Minecraft proxy) in lite mode with a generated config. Category games. Depends on `common` 32.8.5.

## Runtime deps
- Image: `ghcr.io/minekube/gate`, tag `latest@sha256:5c70572b67dabba01d0bcb309c6b8f8baeb55dd8004428ba0bcb1e3aeecbf69a`, pullPolicy IfNotPresent.

## Entrypoint/flags
- Not set in chart (image ENTRYPOINT used; upstream ENTRYPOINT `/gate`).
- Container: tty true, stdin true.

## Config file (configmap `config`)
- Key `config.yml` mounted via persistence `config-file` (type configmap, objectName config) at mountPath `/config.yml` with subPath `config.yml`.
- Content: `config.bind: 0.0.0.0:{{ service.main.ports.main.port }}`; `config.query.enabled: true`, `query.port: {{ service.main.ports.query.port }}`, `showPlugins: false`; `lite.enabled: true` with route `host: minecraft.local`, `backend: localhost:25565`.
- Chart comments link to gate docs (guide/lite, guide/config).

## Env vars
- None set in chart values.

## Ports
- service.main `main`: 25565/tcp (enabled).
- service.main `query`: 25565/udp (enabled; query port).

## Volumes/paths
- Config mount `/config.yml` (file, not a directory) from configmap.
- No other persistence in chart.

## User/UID
- No securityContext set in chart values.

## Healthcheck/probes
- liveness, readiness, startup all `type: tcp` (no port set; default service port).

## Version/asset naming
- Chart 5.0.0. Image uses `latest` tag pinned by digest (not a version tag).

## Gotchas
- Mount path `/config.yml` is a file at container root, not a config directory; upstream config location was not verified from the fetched files.
- Chart `appVersion` is `latest` (no concrete version).
