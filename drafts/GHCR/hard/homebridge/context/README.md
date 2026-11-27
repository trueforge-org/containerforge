# Context: homebridge

Fetched 2026-11-27. Sources from urls.txt.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebridge/values.yaml | truecharts-homebridge.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homebridge/Chart.yaml | truecharts-homebridge.md |
| https://github.com/homebridge/docker-homebridge/blob/2026-11-15/Dockerfile | github-homebridge-docker-homebridge.md (same as raw) |
| https://raw.githubusercontent.com/homebridge/docker-homebridge/2026-11-15/Dockerfile | github-homebridge-docker-homebridge.md |
| https://github.com/homebridge/docker-homebridge/tree/2026-11-15 | github-homebridge-docker-homebridge.md (tag reference; Dockerfile used) |
| https://api.github.com/repos/homebridge/homebridge/releases/latest | github-homebridge-releases.md (403) |
| https://api.github.com/repos/homebridge/homebridge-apt-pkg/releases/latest | github-homebridge-releases.md (403) |
| https://github.com/homebridge/homebridge | not fetched (alternative releases HTML only, see releases file) |
| https://homebridge.io | not fetched (same site as docs) |
| https://homebridge.io/docs | fetched; SPA shell, no usable text |
| https://github.com/oznu/docker-homebridge | HTTP 200, not fetched (legacy repo) |

## Skipped
- Image refs: ghcr.io/homebridge/homebridge.
- Pinned tag rather than release list used for version.

## Failures
- https://api.github.com/repos/homebridge/homebridge/releases/latest: HTTP 403 (rate limit). Alternative https://github.com/homebridge/homebridge/releases/latest: HTTP 200, HTML lists v2.5.0 (not verified as latest). Recorded in github-homebridge-releases.md.
- https://api.github.com/repos/homebridge/homebridge-apt-pkg/releases/latest: HTTP 403 (rate limit). No alternative tried.

## plan.md corrections
- none checked; no conflicts proven.
