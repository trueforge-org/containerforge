# Context index: papermerge

| Source URL | File |
| --- | --- |
| https://github.com/papermerge/papermerge-core/blob/831c2e355cf5c841c4587fea19d89e9b46a92b79/docker/standard/Dockerfile | dockerfile-standard.md |
| (entrypoint referenced by the Dockerfile, raw) | entrypoint-sh.md |
| https://github.com/papermerge/papermerge-core (README via raw master) | readme-papermerge-core.md |
| https://api.github.com/repos/papermerge/papermerge-core/releases/latest (replaces releases/tag/3.5.3) | github-releases-latest.md |
| https://github.com/ciur/papermerge | ciur-papermerge-readme.md |
| https://docs.papermerge.io | docs-3.5.md |
| https://docs.papermerge.io/3.5/ (follow-up) | docs-3.5.md |
| https://docs.papermerge.io/3.5/setup/docker/ (follow-up) | docs-3.5.md |
| https://hub.docker.com/r/papermerge/papermerge | dockerhub-papermerge.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/papermerge (values.yaml via raw) | truecharts-chart-values.md |
| https://papermerge.com | papermerge-com.md |

Skipped categories: none (no CLA, forgetool, containerforge, templated, binary or image-ref URLs in the list).

## Failures
- none

## plan.md corrections
- None applied. Unverified conflicts (not applied): port 8000 (hub) vs 12000 (docs 3.5 / truecharts) vs 80 in image; env naming PAPERMERGE__MAIN__SECRET_KEY (hub 3.6 tag) vs PAPERMERGE__SECURITY__SECRET_KEY (docs 3.5) vs PM_SECRET_KEY (entrypoint). Dockerfile is at an unreleased commit (python 3.14, auth-server image 1.2), not 3.5.3.
