# Docker Hub jez500/bender and TrueCharts bender chart

## Source URL(s) + date
- https://hub.docker.com/r/jez500/bender (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bender/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bender/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bender not parsed.

## Docker Hub
- Title: "jez500/bender - Docker Image"
- Meta description: "A link dashboard that can be managed completely via the browser"
- JS-rendered; tags not extractable.

## Chart (reference only)
- `bender` chart version 11.0.0, appVersion 1.0.3. Description: "A link dashboard that can be managed without any code."
- Depends on `common` 32.8.5.
- Image `docker.io/jez500/bender`, tag `1.0.3@sha256:32983833590fb1662742065cbd2ff209e0d913cd373a46f075aa482aa7ee5fc9`.
- Value `bender.init_assets: true` -> env `INIT_ASSETS` = `1` (ternary).
- Service main: http, port 10353 -> targetPort 8080.
- Persistence: `config` -> `/app/static`.
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- Chart mounts `/app/static` (upstream layout). plan.md moves persistence to `/config/static` via symlink.
