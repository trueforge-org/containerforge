# Context README: pigallery2

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pigallery2/values.yaml | truecharts-pigallery2.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pigallery2/Chart.yaml | truecharts-pigallery2.md |
| https://hub.docker.com/v2/repositories/bpatrik/pigallery2/ | dockerhub-pigallery2.md |
| https://hub.docker.com/v2/repositories/bpatrik/pigallery2/tags?page_size=10 | dockerhub-pigallery2.md |
| https://api.github.com/repos/bpatrik/pigallery2/releases/latest | github-pigallery2.md |
| https://raw.githubusercontent.com/bpatrik/pigallery2/43f348a254142eea521138b783e3b8df9fe547c8/docker/alpine/Dockerfile.build | github-pigallery2.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads (release zip, not fetched); image refs/none; GitHub repo HTML and blob view, GitHub Pages docs (budget, not fetched).

Failures: none.

## plan.md corrections
- None. Verified: release 3.8.0 with `pigallery2-release.zip`; Dockerfile both stages `node:26-alpine3.24`, `EXPOSE 80`, `/heartbeat` healthcheck, config path `/app/data/config/config.json`.
- Plan lists port env/config key as UNVERIFIED; the fetched Dockerfile shows only `default-*` ENV overrides for db/media/temp/extensions folders, no port key. Not edited.
