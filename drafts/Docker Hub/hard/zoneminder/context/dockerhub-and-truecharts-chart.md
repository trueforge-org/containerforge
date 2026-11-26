# Docker Hub dlandon/zoneminder.unraid and TrueCharts zoneminder chart

## Source URL(s) + date
- https://hub.docker.com/r/dlandon/zoneminder.unraid (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zoneminder/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zoneminder/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zoneminder not parsed.

## Docker Hub
- Title: "dlandon/zoneminder.unraid - Docker Image"
- Meta description: "Zoneminder Docker for Unraid."
- JS-rendered; tags not extractable.

## Chart (reference only)
- `zoneminder` chart version 11.0.0, appVersion `latest`. Description: "Zoneminder is the top Linux video camera security and surveillance solution."
- Depends on `common` 32.8.5.
- Image `docker.io/dlandon/zoneminder.unraid`, tag `latest@sha256:6844bffc426668e1bb3611ca6218b871bc7b64ff20fc2b700ca590ee4f31900a`.
- Service main: https, port 10292 -> targetPort 443. Service `zmninja`: tcp, port 10293 -> targetPort 9000.
- Persistence: `config` -> `/config`; `datapath` -> `/var/cache/zoneminder`; `varrun` disabled.
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; container capabilities add `KILL` ("init script stops the temporary MariaDB with killall").
- Probes (liveness, readiness, startup): HTTP path `/zm`.

## Gotchas
- Chart value `KILL` capability is for the upstream init script; plan.md says the ContainerForge version does not need it (non-root).
- Chart uses `latest` digest, not a pinned ZM version.
