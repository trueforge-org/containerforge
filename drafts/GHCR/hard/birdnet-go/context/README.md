# Context index: birdnet-go

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/birdnet-go/values.yaml + Chart.yaml | truecharts-birdnet-go.md |
| https://raw.githubusercontent.com/tphakala/birdnet-go/bc1e0de.../Dockerfile (+ Docker/entrypoint.sh) | github-birdnet-go-dockerfile.md |
| https://api.github.com/repos/tphakala/birdnet-go/releases/tags/20261031 (403) + https://github.com/tphakala/birdnet-go/releases/tag/20261031 | github-birdnet-go-release.md |

Skipped categories: GitHub blob Dockerfile (same as raw), github repo root and wiki pages (not needed for build), blob LICENSE (`blob/main/LICENSE`, main branch, not read), Docker Hub (image is GHCR, no Docker Hub URL listed).

Failures:
- https://api.github.com/repos/tphakala/birdnet-go/releases/tags/20261031: 403 (rate limit). Alternative used: release HTML page (200, tag exists).

## plan.md corrections
- No edit made. Plan says the entrypoint scripts were not fetched and that their behavior is UNVERIFIED; they are now summarised in github-birdnet-go-dockerfile.md (Docker/entrypoint.sh) for the maintainer to check against start.sh.
- Unverified conflict: plan says `ghcr.io/tphakala/birdnet-go:20261031` copy-from is unverified; the release tag 20261031 exists, but the image tag was not checked.
