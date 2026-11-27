# Context: shelfmark

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shelfmark/values.yaml + Chart.yaml | truecharts-shelfmark.md |
| https://raw.githubusercontent.com/calibrain/shelfmark/0d97110f0132d78147213d11902298c516c32f16/Dockerfile (blob variant listed); https://raw.githubusercontent.com/calibrain/shelfmark/main/Dockerfile | shelfmark-dockerfile.md |
| https://github.com/calibrain/shelfmark/releases/tag/v1.7.0 (HTML fallback for failed API) | shelfmark-release.md |

Skipped (not fetched): Docker Hub (image on GHCR); the upstream tarball archive URLs (source download, not fetched); ghcr.io/calibrain/shelfmark image copy-from (plan says not used); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://raw.githubusercontent.com/calibrain/shelfmark/main/README.md: 404.
- https://github.com/calibrain/shelfmark/blob/main/README.md: 404 (tried as the one alternative). README content unavailable, so the plan's README-based env list (FLASK_PORT, INGEST_DIR, PUID/PGID, WIREGUARD_*, LOG_LEVEL) is unverified.
- https://api.github.com/repos/calibrain/shelfmark/releases/tags/v1.7.0: 403. HTML release page used instead.

## plan.md corrections
- None applied.
- Conflict (not edited): plan line 8 says the draft chart image is `v1.7.0`, "same" as the target. The fetched TrueCharts chart pins `ghcr.io/calibrain/shelfmark:v1.7.2` and appVersion 1.7.2. The plan's "latest stable release v1.7.0" claim could not be checked against the API, and a newer v1.7.2 tag is implied by the chart. Owner should decide the target version.
- Conflict (not edited): plan line 15 reviews the Dockerfile on `main` (uv 0.13.9, python 3.14.10-slim), which matches the fetched main. The pinned commit 0d97110 uses uv 0.13.7 and python 3.14.9-slim. Plan step 1 pins `v1.7.0` as the tag, so the Dockerfile for that tag should be re-read at build time.
- Unverified: plan line 10 licence MIT and "pushed 2026-11-25" come from the API call that failed.
