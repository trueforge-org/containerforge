# Context: frigate

Fetched 2026-11-27. Sources from urls.txt.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/frigate/values.yaml | truecharts-frigate.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/frigate/Chart.yaml | truecharts-frigate.md |
| https://raw.githubusercontent.com/blakeblackshear/frigate/a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676/docker/main/Dockerfile | github-blakeblackshear-frigate.md |
| https://github.com/blakeblackshear/frigate/blob/a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676/docker/main/Dockerfile | github-blakeblackshear-frigate.md (same file) |
| https://github.com/blakeblackshear/frigate | github-blakeblackshear-frigate.md (repo, Dockerfile used) |
| https://github.com/blakeblackshear/frigate/releases/tag/v0.18.3 | not fetched; tag matches chart appVersion 0.18.3 |

## Skipped
- Image refs: ghcr.io/blakeblackshear/frigate, tensorrt image.
- Pinned commit sources duplicated (blob/HEAD requirements.txt not fetched; repo files under docker/main/ noted in Dockerfile file).
- Not fetched by budget: docs.frigate.video, frigate.video, github requirements.txt (repo file).

## Failures
- https://api.github.com/repos/blakeblackshear/frigate/releases/latest: HTTP 403 (rate limit). No alternative tried; the pinned tag v0.18.3 is used.
- https://api.github.com/repos/blakeblackshear/frigate/license: not fetched (same API rate limit expected; not retried).

## plan.md corrections
- none checked; no conflicts proven.
