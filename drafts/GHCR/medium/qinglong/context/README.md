# Context: qinglong

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qinglong/values.yaml + Chart.yaml | truecharts-qinglong.md |
| https://raw.githubusercontent.com/whyour/qinglong/6e26899a235a955713edfb490f6ae538d0baf612/docker/Dockerfile | qinglong-dockerfile.md |
| https://raw.githubusercontent.com/whyour/qinglong/develop/docker/docker-entrypoint.sh | qinglong-entrypoint.md |
| https://github.com/whyour/qinglong/releases/tag/v2.24.0 (fallback), https://qinglong.online/guide/getting-started/installation-guide (+ /docker) | qinglong-release-and-docs.md |

Skipped (not fetched): Docker Hub (image is on GHCR, no Docker Hub source); GitHub repo root and qinglong.online home; git tag archive URL (plan marks it UNVERIFIED); github.com Dockerfile blob URL (raw variant used); CLA; forgetool schemas; containerforge app links.

Failures:
- https://api.github.com/repos/whyour/qinglong/releases/tags/v2.24.0: 403. Alternative https://github.com/whyour/qinglong/releases/tag/v2.24.0 fetched and used for date/title.

## plan.md corrections
- None applied.
- Unverified conflict: plan uses `ql_port` / `ql_grpc_port` (from share.sh, not fetched). Docs say the panel port is set by env `QlPort` (default 5700) and base path by `QlBaseUrl`. Not confirmed against share.sh.
- Release date in plan (2026-10-29) matches the release page datetime.
