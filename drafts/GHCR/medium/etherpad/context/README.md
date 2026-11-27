# etherpad context

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/etherpad/values.yaml + Chart.yaml | truecharts-etherpad.md |
| https://raw.githubusercontent.com/ether/etherpad/844729c6b9e68d593da9928141e6e2daced53ec9/Dockerfile | github-etherpad-dockerfile.md |
| https://api.github.com/repos/ether/etherpad/releases/latest (via `gh api`) | github-api-etherpad-release.md |
| https://raw.githubusercontent.com/ether/etherpad/844729c6b9e68d593da9928141e6e2daced53ec9/settings.json.docker | github-etherpad-settings-docker.md |

Skipped: Docker Hub (image is ghcr.io, no Docker Hub page); deb binary downloads (`etherpad_3.3.22-1_*.deb`); etherpad.org, github repo root and etherpad-lite (marketing/redirect, not build-relevant); blob-URL duplicate of the Dockerfile.

Failures: none. The unauthenticated api.github.com call was rate-limited (403); the same URL was retried once through `gh api`, which succeeded.

## plan.md corrections
None. Plan version (v3.3.22), port (9001), UID (5001), healthcheck and env defaults match the fetched sources.
