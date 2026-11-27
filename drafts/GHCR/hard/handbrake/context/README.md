# Context: handbrake

Fetched 2026-11-27. Sources from urls.txt.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/handbrake/values.yaml | truecharts-handbrake.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/handbrake/Chart.yaml | truecharts-handbrake.md |
| https://github.com/jlesage/docker-handbrake/blob/v26.09.1/Dockerfile | github-jlesage-docker-handbrake.md (same file as raw) |
| https://raw.githubusercontent.com/jlesage/docker-handbrake/v26.09.1/Dockerfile | github-jlesage-docker-handbrake.md |
| https://github.com/jlesage/docker-handbrake | github-jlesage-docker-handbrake.md (README followed) |
| https://github.com/HandBrake/HandBrake | HTTP 200, not read (source tarball URL used in Dockerfile) |
| https://handbrake.fr | not fetched (budget) |
| https://handbrake.fr/docs | not fetched (budget) |

## Skipped
- Image refs: ghcr.io/jlesage/handbrake.
- Build-time: jlesage/docker-templates icon, GitHub release tarballs (not downloaded).

## Failures
- https://api.github.com/repos/HandBrake/HandBrake/releases/latest: not in urls.txt; API 403 (rate limit). Release tarball version taken from Dockerfile ARG (1.11.2).

## plan.md corrections
- none checked; mismatch noted: chart appVersion 26.11.2 vs urls.txt pinned Dockerfile v26.09.1 (not a proven plan.md error).
