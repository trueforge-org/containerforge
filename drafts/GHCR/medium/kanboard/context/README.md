# Context: kanboard

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kanboard/values.yaml + Chart.yaml | truecharts-kanboard.md |
| https://raw.githubusercontent.com/kanboard/kanboard/v1.2.57/Dockerfile | github-kanboard-dockerfile-v1-2-57.md |

Skipped: GitHub HTML pages (blob v1.2.57, releases/tag v1.2.57, repo root kanboard/kanboard) and the release asset metadata (no release assets per plan). No Docker Hub URL (image is GHCR).

Failures:
- https://api.github.com/repos/kanboard/kanboard: 403 (not retried).
- https://api.github.com/repos/kanboard/kanboard/releases/tags/v1.2.58: 403 (not retried). No alternative fetched.

Gap: upstream entrypoint at /usr/local/bin/entrypoint.sh (repo `docker/` tree) not fetched; no path guessed.

## plan.md corrections
- None proven. Plan's v1.2.57 Dockerfile reference and base/ports match the fetched Dockerfile. The v1.2.58 release date and "latest" claim (plan line 8) could not be verified (API 403).
