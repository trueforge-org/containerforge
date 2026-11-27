# Context: organizr

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/organizr/values.yaml + Chart.yaml | truecharts-organizr.md |
| https://raw.githubusercontent.com/Organizr/docker-organizr/53b8b05/Dockerfile (+ raw variant) | organizr-docker-dockerfile.md |
| https://github.com/Organizr/docker-organizr (README via raw master/README.md) | organizr-docker-readme.md |
| https://github.com/causefx/Organizr/releases/latest (alt for API 403) and https://github.com/causefx/Organizr/releases/tag/1.90 (covered by latest redirect, tag 1.90) | organizr-release-latest.md |
| https://docs.organizr.app | organizr-docs-site.md |

Skipped: https://github.com/causefx/Organizr (repo root, not fetched); https://github.com/causefx/Organizr/releases/tag/1.90 (tag already confirmed from the latest redirect); https://github.com/Organizr/docker-organizr/blob/53b8b05/Dockerfile (duplicate of raw); https://github.com/Organizr/docker-organizr (repo root, covered by raw README/Dockerfile). No Docker Hub REQUIRED URL in urls.txt (GHCR image).

Failures:
- https://api.github.com/repos/causefx/Organizr/releases/latest: HTTP 403; alternative used.

## plan.md corrections
- No edit made (conflict, not a simple value fix). UNVERIFIED conflict: plan.md (VERSION 1.90, section 4 step 3 "Download the Organizr 1.90 source archive") vs upstream docker-organizr: the image does not bundle Organizr; it fetches code at start by `branch` (default v2-master). The 1.90 tag is not what the upstream image runs by default. Plan should decide which source to bake in.
- Upstream PHP/nginx versions still unknown: base ghcr.io/organizr/base:2026-11-20_10 not fetched.
- Upstream Dockerfile has no USER, no ENTRYPOINT: plan.md line 18 consistent.
