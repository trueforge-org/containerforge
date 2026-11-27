# Context index: st-reborn-server

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/st-reborn-server/values.yaml | truecharts-st-reborn-server.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/st-reborn-server/Chart.yaml | truecharts-st-reborn-server.md |
| https://hub.docker.com/v2/repositories/tiltedphoques/st-reborn-server/ | dockerhub-st-reborn-server.md |
| https://hub.docker.com/v2/repositories/tiltedphoques/st-reborn-server/tags?page_size=10 | dockerhub-st-reborn-server.md |
| https://raw.githubusercontent.com/tiltedphoques/TiltedEvolution/v1.8.4/Dockerfile | github-tiltedevolution-dockerfile.md |

Skipped categories: GitHub HTML pages (`github.com/tiltedphoques/TiltedEvolution`, `blob/v1.8.4/Dockerfile`) covered by the raw Dockerfile.

Failures:
- https://api.github.com/repos/tiltedphoques/TiltedEvolution/releases/latest: HTTP 403 (API rate limit). Single attempt, not retried, no alternative fetched. Release tag/asset names unverified by this pass.

## plan.md corrections
None edited. Checked and consistent: appVersion/tag 1.8.4 and digest; Docker Hub 1.8.4 amd64+arm64 (last_updated 2026-10-22); UDP 10578 as the only port in the upstream Dockerfile; debian:12 builder and debian:12-slim runtime; WORKDIR /st-server; ENTRYPOINT.
Unverified (not edited): plan line 8 "published 2026-10-22" for the GitHub release (release API was rate-limited; Docker Hub tag date matches, not the release date); tarball asset names (plan line 13-14); LICENSE (not fetched).
