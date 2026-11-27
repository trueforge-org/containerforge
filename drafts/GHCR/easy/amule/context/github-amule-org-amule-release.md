# GitHub: amule-org/amule release 3.2.0 (upstream app)

## Source URL(s) + date
- https://github.com/amule-org/amule/releases/latest (HTML, 2026-11-27, HTTP 200; used as fallback)
- Not fetched: https://api.github.com/repos/amule-org/amule/releases/latest (HTTP 403 rate limit; one alternative used).
- Not fetched: https://github.com/amule-org/amule (repo root; release page and docs cover version).

## What it is
- aMule upstream source. Latest release title: "Release aMule 3.2.0" (tag 3.2.0).
- Release asset names (per plan.md, from the API via gh, not re-verified here): `aMule-3.2.0-Linux-x64-static.tar.gz`, `aMule-3.2.0-Linux-arm64-static.tar.gz`.
- Upstream Dockerfile builds `AMULE_REF=3.2.0` from git tag (not the release tarball).

## Version / tag naming
- Tag `3.2.0` (no `v` prefix). Image tag `3.2.0-1` (ngosang revision suffix).

## Gotchas
- API release metadata (asset digests, publish time) not verified in this run (403).
- Asset names above come from plan.md; the HTML page did not expose asset filenames in static text.
