# ghostfolio context

| Source URL | File |
| --- | --- |
| https://github.com/ghostfolio/ghostfolio/blob/45d692301c1e9c0dca5bcc77cb06a9e408af019c/Dockerfile | github-ghostfolio-dockerfile.md |
| https://raw.githubusercontent.com/ghostfolio/ghostfolio/45d692301c1e9c0dca5bcc77cb06a9e408af019c/docker/entrypoint.sh | github-ghostfolio-entrypoint.md |
| https://raw.githubusercontent.com/ghostfolio/ghostfolio/main/README.md (github repo root) | github-ghostfolio-readme.md |
| https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest (also tag 3.100.0) | github-ghostfolio-releases.md |
| https://hub.docker.com/r/ghostfolio/ghostfolio | dockerhub-ghostfolio-ghostfolio.md |
| https://ghostfol.io | dockerhub-ghostfolio-ghostfolio.md (title only returned) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ghostfolio | truecharts-ghostfolio.md |
| raw values.yaml of the same chart (follow-up) | truecharts-ghostfolio.md |

Skipped: none of the listed categories applied. Invalid placeholder `http://..:3333` in urls.txt was not fetched.

Failures: none (no 403/404/DNS errors). ghostfol.io returned only the page title, so no license or install detail was taken from it.

## plan.md corrections
None. Version 3.100.0, Dockerfile steps, entrypoint, port 3333 and AGPL license match fetched sources.
Notes (not edits): README documents `PORT` (default 3333), which resolves plan UNVERIFIED on PORT only partly (it is a documented env var). README lists REDIS_* as required services. TrueCharts values.yaml also sets `ALPHA_VANTAGE_API_KEY`, not in plan env list (chart-only, not upstream README).
