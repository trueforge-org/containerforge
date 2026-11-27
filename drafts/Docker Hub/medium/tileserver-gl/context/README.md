# Context index: tileserver-gl

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tileserver-gl/values.yaml | truecharts-tileserver-gl.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tileserver-gl/Chart.yaml | truecharts-tileserver-gl.md |
| https://hub.docker.com/v2/repositories/maptiler/tileserver-gl/ | dockerhub-tileserver-gl.md |
| https://hub.docker.com/v2/repositories/maptiler/tileserver-gl/tags?page_size=10 | dockerhub-tileserver-gl.md |
| https://raw.githubusercontent.com/maptiler/tileserver-gl/master/Dockerfile | github-tileserver-gl-dockerfile.md |
| https://tileserver.readthedocs.io | readthedocs-tileserver-gl.md |

Also fetched as follow-ups (same site, not in list): `en/latest/usage.html`, `en/latest/endpoints.html` (merged into readthedocs-tileserver-gl.md).

Skipped categories: GitHub HTML pages (`github.com/maptiler/tileserver-gl`, `blob/243c4de.../Dockerfile`) covered by the raw master Dockerfile (the pinned-commit raw URL was not in the list).

Failures: none.

## plan.md corrections
None edited. Checked and consistent: v5.7.0 tag and chart pin; Dockerfile (ubuntu:noble, Node 24 NodeSource, EXPOSE 8080, VOLUME/WORKDIR /data, USER node:node, HEALTHCHECK); default port 8080 (docs); `/data` path.
Unverified (not edited): BSD-2-Clause license (LICENSE file not fetched; GitHub reports NOASSERTION); engines range (npm not fetched); CLI flag list (src/main.js not fetched); entrypoint script (not fetched).
Doc conflict (no plan edit needed): Docker Hub README example maps `8080:80`, while upstream EXPOSE and docs say 8080. Plan's 8080 is right.
