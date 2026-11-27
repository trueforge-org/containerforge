# Context: humhub

Fetched 2026-11-27. Sources from urls.txt.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/humhub/values.yaml | truecharts-humhub.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/humhub/Chart.yaml | truecharts-humhub.md |
| https://hub.docker.com/v2/repositories/library/nginx/ | dockerhub-nginx.md |
| https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=10 | dockerhub-nginx.md |
| https://github.com/mriedmann/humhub-docker/blob/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile | github-mriedmann-humhub-docker.md (same as raw) |
| https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile | github-mriedmann-humhub-docker.md |
| https://api.github.com/repos/humhub/humhub/releases/latest | github-humhub-releases.md (403) |
| https://github.com/humhub/humhub/releases | github-humhub-releases.md |
| https://github.com/humhub/humhub | not fetched (archive tarball used by Dockerfile) |
| https://docs.humhub.org | fetched; no install/env facts extracted (budget) |

## Skipped
- Image refs: ghcr.io/mriedmann/humhub-nginx, humhub-phponly.

## Failures
- https://api.github.com/repos/humhub/humhub/releases/latest: HTTP 403 (rate limit). Alternative https://github.com/humhub/humhub/releases used (HTML, no asset data).

## plan.md corrections
- none checked; no conflicts proven. Observation: chart pins 1.17.2 while HTML releases page lists v1.19.5 first (not a proven plan error).
