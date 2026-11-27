# Context: humhub

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/humhub/Chart.yaml + values.yaml | truecharts-humhub.md |
| https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile (also blob URL) | github-mriedmann-humhub-docker-dockerfile.md |
| https://api.github.com/repos/humhub/humhub/releases/tags/v1.17.2 | FAILED (403 rate limit) |
| https://github.com/humhub/humhub/releases/tag/v1.17.2 | FAILED (alternative HTML fetched, no asset list extracted; tag is a source tarball only per Dockerfile ADD) |
| https://github.com/humhub/humhub | not fetched (budget; source tarball URL taken from upstream Dockerfile) |

Skipped categories: none beyond the list (no CLA, templated or binary URLs listed).

Failures: API release lookup 403 (rate limit); HTML release page gave no usable asset data.

## plan.md corrections
None. Plan's upstream Dockerfile facts (alpine 3.19.4, php82, nginx 1.27.2-alpine, uid 100/gid 101, no USER, port 9000 phponly, VOLUME list, CMD supervisord) match the fetched Dockerfile.
