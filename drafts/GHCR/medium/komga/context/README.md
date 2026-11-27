# Context: komga

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/komga/values.yaml + Chart.yaml | truecharts-komga.md |
| https://raw.githubusercontent.com/gotson/komga/1.30.1/komga/docker/Dockerfile.tpl | github-gotson-komga-dockerfile-tpl-1-30-1.md |
| https://komga.org/docs/introduction | komga-docs-introduction.md |

Skipped: GitHub HTML (repo root, blob Dockerfile.tpl 1.30.1). komga.org root page (docs intro used). No Docker Hub URL (image is GHCR).

Failures:
- https://api.github.com/repos/gotson/komga: 403 (not retried).
- https://api.github.com/repos/gotson/komga/releases/latest: 403 (not retried). Release 1.30.2 and its checksum file unverified here.

## plan.md corrections
- None proven. Plan's upstream Dockerfile reference, EXPOSE 25600, env and VOLUME match the fetched template. The 1.30.2 "latest" claim and the sha256 of komga-1.30.2.jar in plan lines 8 and 13 could not be verified (API 403).
