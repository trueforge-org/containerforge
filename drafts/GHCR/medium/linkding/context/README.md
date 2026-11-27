# Context: linkding

Fetched 2026-11-27. Sources taken from urls.txt.

## Source -> file

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkding/values.yaml | truecharts-linkding.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/linkding/Chart.yaml | truecharts-linkding.md |
| https://raw.githubusercontent.com/sissbruecker/linkding/24b5ad6/docker/default.Dockerfile | github-linkding-dockerfile.md |
| https://github.com/sissbruecker/linkding/blob/24b5ad6/docker/default.Dockerfile | github-linkding-dockerfile.md (same file) |
| https://raw.githubusercontent.com/sissbruecker/linkding/v1.47.0/bootstrap.sh | github-linkding-bootstrap.md |
| https://linkding.link (install/options docs) | linkding-docs-options.md (options page https://linkding.link/options/) |
| https://github.com/sissbruecker/linkding/releases/tag/v1.47.0 | not summarised (HTML page; only JS/boilerplate extracted) |

## Skipped
- Docker Hub: not applicable, image is ghcr.io only (no Docker Hub page).
- https://api.github.com/repos/sissbruecker/linkding and /releases/latest: not fetched, see failures.
- https://github.com/sissbruecker/linkding (repo root): covered by the Dockerfile and bootstrap sources.
- Image refs (ghcr.io/sissbruecker/linkding) and the uv installer/ICU/SQLite download URLs inside the Dockerfile: not fetched.

## Fetch failures
- https://api.github.com/repos/sissbruecker/linkding/releases/latest: HTTP 403 (unauthenticated rate limit). One alternative tried (release tag HTML page); asset list not extracted. Version 1.47.0 is confirmed by the TrueCharts appVersion.

## plan.md corrections
- None. Facts checked (9090 port, `/etc/linkding/data`, bootstrap steps, no USER, `CMD ["./bootstrap.sh"]`) match the fetched sources.
- Unverified in plan, not resolved here: release publish date 2026-09-13 (API blocked); `create_initial_superuser` env var names (management command source not fetched).
