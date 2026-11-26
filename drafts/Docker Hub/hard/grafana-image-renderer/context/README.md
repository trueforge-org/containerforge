# grafana-image-renderer context

| Source URL | File |
| --- | --- |
| https://github.com/grafana/grafana-image-renderer/blob/76ca73f6e1f00b46ee91524bbd91718545ea5943/Dockerfile | github-grafana-image-renderer-dockerfile.md |
| https://raw.githubusercontent.com/grafana/grafana-image-renderer/master/README.md (repo root) | github-grafana-image-renderer-readme.md |
| https://github.com/grafana/grafana-image-renderer/blob/master/docs/remote_rendering_using_docker.md | FAILED (404 on github, 404 on raw alternative); no file |
| https://hub.docker.com/r/grafana/grafana-image-renderer | dockerhub-grafana-image-renderer.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/grafana-image-renderer | truecharts-grafana-image-renderer.md (via raw values.yaml; tree page not fetched) |

Skipped: none of the listed categories applied.

Failures: 1. `remote_rendering_using_docker.md` returned 404 at both the blob URL and the raw master alternative.

## plan.md corrections
None edited. Unverified conflicts:
- plan.md says the Chromium minimum is 156.0.8078.108 (upstream reviewed on master). The Dockerfile at the pinned commit 76ca73f sets `ARG CHROMIUM_VERSION=156.0.8078.79`. Source: github-grafana-image-renderer-dockerfile.md. Likely master drift, not checked.
- plan.md version 5.12.11 and asset digests were not re-verified (release API not called for this app).
- Upstream runs `tini` in ENTRYPOINT; the plan relies on the base image tini. Not a conflict, noted for build.
