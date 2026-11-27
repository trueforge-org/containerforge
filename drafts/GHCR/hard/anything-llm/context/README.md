# Context index: anything-llm

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anything-llm/values.yaml + Chart.yaml | truecharts-anything-llm.md |
| https://raw.githubusercontent.com/Mintplex-Labs/anything-llm/eb498cf2c211/docker/Dockerfile + docker-entrypoint.sh, https://github.com/Mintplex-Labs/anything-llm/releases/latest | github-anything-llm.md |

Skipped categories: blob variant of the Dockerfile (same as raw), repo HTML page and homepage (covered by raw/API data), GitHub API release call (403 rate limit; the HTML releases redirect was used instead).
Docker Hub: not listed in urls.txt; image is on GHCR (`ghcr.io/mintplex-labs/anything-llm`), so no Docker Hub fetch.

Failures:
- https://api.github.com/repos/Mintplex-Labs/anything-llm/releases/latest: 403 (rate limit). Alternative used: releases/latest redirect (v1.20.0).
- https://docs.anythingllm.com/installation-docker/quickstart: fetched, page returned navigation only, no install content. Not summarised.

## plan.md corrections
- None.
