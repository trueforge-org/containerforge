# dispatcharr context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dispatcharr/values.yaml | truecharts-dispatcharr-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dispatcharr/Chart.yaml | truecharts-dispatcharr-chart.md |
| https://hub.docker.com/v2/repositories/library/alpine/ and /tags?page_size=10 | dockerhub-alpine.md |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/83f82bf388b72ec1e6cc356f1015a9812228b424/docker/Dockerfile | dispatcharr-dockerfile.md |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/docker/docker-compose.aio.yml (raw of blob URL) | dispatcharr-compose-aio.md |
| https://github.com/Dispatcharr/Dispatcharr/releases/tag/v0.34.1 (HTML fallback) | dispatcharr-release-v0.34.1.md |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/README.md (not in urls.txt) | dispatcharr-readme.md |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/docker/Dockerfile (diff vs pinned commit: identical, no file) | see dispatcharr-dockerfile.md |

Skipped: github.com blob URLs (same content as raw), github.com repo root (HTML), Dispatcharr docs site content (JS-only shell, see dispatcharr-readme.md).

Failures:
- https://api.github.com/repos/Dispatcharr/Dispatcharr/releases/tags/v0.34.1: HTTP 403. One alternative (HTML release page) used.
- https://dispatcharr.github.io/Dispatcharr-Docs: returned JS-rendered shell only, no content (not summarized).

## plan.md corrections
- plan.md line 14: the pinned commit `83f82bf` was reported as "could not be fetched". It fetched successfully (raw URL, HTTP 200), and `docker/Dockerfile` at 83f82bf is byte-identical to `main` (checked 2026-11-27). Edited that line to say so.
- Unverified (not edited): plan.md line 16 base image contents, line 17 entrypoint.sh (not fetched in this batch).
