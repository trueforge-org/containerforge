# Context: bender

| Source URL | File |
| --- | --- |
| https://github.com/jez500/bender | jez500-bender-dockerfile-entrypoint-readme.md |
| https://github.com/jez500/bender/blob/fd780e5/Dockerfile | jez500-bender-dockerfile-entrypoint-readme.md |
| https://github.com/jez500/bender/releases/tag/1.0.3 | FAILED: GitHub API `releases/tags/1.0.3` 404; `releases/latest` also 404 (repo has tags only, no releases). Not summarised. |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bender | dockerhub-and-truecharts-chart.md |
| https://hub.docker.com/r/jez500/bender | dockerhub-and-truecharts-chart.md |

Skipped categories: none (urls.txt pre-filtered).

Failures:
- https://github.com/jez500/bender/releases/tag/1.0.3: 404 via API (`releases/tags/1.0.3`); one extra attempt `releases/latest` also 404. Tag exists per plan (commit fd780e5), no release object.

## plan.md corrections
- L17 "Env": `INIT_ASSETS` default attributed to entrypoint.sh; changed to the upstream Dockerfile `ENV INIT_ASSETS 1` (entrypoint.sh only checks `== "1"`). Source: Dockerfile at fd780e5 and entrypoint.sh at fd780e5.
- Unverified (not edited): plan L10 license (Apache-2.0, LICENSE file not fetched); plan L14 Nuxt 2 stack; plan L8 "repo inactive since 2022-09" not checked.
