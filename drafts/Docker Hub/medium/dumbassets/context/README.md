# context README: dumbassets

| Source URL | File |
| --- | --- |
| https://github.com/DumbWareio/DumbAssets | upstream-github.md (repo root, covered) |
| https://github.com/DumbWareio/DumbAssets/blob/2bacca1e2c4ff8e60d562c8dc300a8dbe91083c3/Dockerfile | upstream-github.md (same as raw) |
| https://raw.githubusercontent.com/DumbWareio/DumbAssets/2bacca1e2c4ff8e60d562c8dc300a8dbe91083c3/Dockerfile | upstream-github.md |
| https://github.com/DumbWareio/DumbAssets/releases/tag/v1.0.11 | upstream-github.md (release API) |
| https://github.com/DumbWareio/dumbassets | upstream-github.md (case variant of repo) |
| https://hub.docker.com/r/dumbwareio/dumbassets | upstream-github.md (Docker Hub section; tags API used, HTML not fetched) |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: none.

## plan.md corrections
- Line 10 (Version row). Old: "git tags `v1.0.0` and `v1.0.11` only; the GitHub Releases page is empty". New: "git tags `v1.0.0` and `v1.0.11`; GitHub release `v1.0.11` exists, published 2025-06-12, with no assets". Source: https://api.github.com/repos/DumbWareio/DumbAssets/releases/latest (returned tag v1.0.11, assets []).
- Not edited: plan says it is UNVERIFIED whether code reads ALLOWED_ORIGINS; server code was not fetched in this pass, so nothing to correct.
