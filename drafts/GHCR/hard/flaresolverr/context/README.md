# flaresolverr context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flaresolverr/values.yaml | truecharts-flaresolverr-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flaresolverr/Chart.yaml | truecharts-flaresolverr-chart.md |
| https://raw.githubusercontent.com/FlareSolverr/FlareSolverr/93125d6ea6956906c8dfa29e169b2dc67d993dc3/Dockerfile | flaresolverr-dockerfile.md |
| https://raw.githubusercontent.com/FlareSolverr/FlareSolverr/HEAD/requirements.txt | flaresolverr-requirements.md |
| https://api.github.com/repos/FlareSolverr/FlareSolverr/releases/tags/v3.5.2 (HTML fallback https://github.com/FlareSolverr/FlareSolverr/releases/tag/v3.5.2) | flaresolverr-release-v3.5.2.md |

Skipped: github.com blob Dockerfile (same as raw), github.com blob HEAD requirements.txt (fetched via the raw HEAD URL instead; same file), github.com repo root (HTML; license in plan.md, not re-fetched). Binary release assets (flaresolverr_linux_x64.tar.gz) not downloaded. Docker Hub / boilerplate: none in urls.txt.

Failures:
- https://api.github.com/repos/FlareSolverr/FlareSolverr: HTTP 403, not retried, no data used (plan.md cites it).
- https://api.github.com/repos/FlareSolverr/FlareSolverr/releases/tags/v3.5.2: HTTP 403. Alternative HTML page used (date recovered, assets not).

## plan.md corrections
- plan.md line 19 (Requirements): said selenium, undetected-chromedriver, bottle, waitress, versions UNVERIFIED. requirements.txt does not list undetected-chromedriver as a line; it pins 11 packages (listed in flaresolverr-requirements.md). Edited the line.
- Verified, no edit: plan.md line 9 release v3.5.2 published 2026-09-12 (HTML page datetime); line 12-14 EXPOSE 8191/8192, VOLUME /config, no ENV/ARG in Dockerfile.
