# Context: rss-bridge

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rss-bridge/values.yaml + Chart.yaml | truecharts-rss-bridge.md |
| https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/Dockerfile (+ blob URL variant) | rss-bridge-dockerfile.md |
| https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/docker-entrypoint.sh | rss-bridge-entrypoint.md |
| https://github.com/RSS-Bridge/rss-bridge/releases/tag/2025-06-03 (HTML fallback), https://rss-bridge.github.io/rss-bridge/index.html | rss-bridge-release-and-docs.md |

Skipped (not fetched): Docker Hub (image on GHCR); api.github.com/repos/RSS-Bridge/rss-bridge root (not attempted, sibling API calls returned 403); github.com repo root (both casings); the Dockerfile blob URL (raw used); curl-impersonate release archives (binary downloads); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://api.github.com/repos/RSS-Bridge/rss-bridge/releases/latest: 403 (not retried). Latest tag could not be checked.
- https://api.github.com/repos/RSS-Bridge/rss-bridge/releases/tags/2025-06-03: 403. HTML release page (github.com) fetched instead: date 2025-06-03T19:25:56Z confirmed, assets not extracted.

## plan.md corrections
- None applied.
- Unverified: plan line 8 (latest release 2025-08-05) and plan line 10 (Unlicense) came from API calls that were not reachable here.
- Conflict (not edited): plan line 14 names the curl-impersonate repo as `lwthiker/curl-impersonate`, tag `v1.0.0-rc2`. The fetched upstream Dockerfile downloads from `lexiforest/curl-impersonate`, tag `v1.0.0rc2`. The plan's "403 for lwthiker" sentence is about an API call not made here, so it was left in place for the owner to check.
- Note: upstream docker-entrypoint.sh's `sed "s/80/$HTTP_PORT/g"` rewrites every "80" in the nginx site file; plan's start.sh rewrite (`listen 80;` → `listen ${HTTP_PORT}`) is narrower and does not carry this behaviour.
