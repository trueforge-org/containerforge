# Sources for bitmagnet (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitmagnet/values.yaml | truecharts-bitmagnet.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitmagnet/Chart.yaml | truecharts-bitmagnet.md |
| https://api.github.com/repos/bitmagnet-io/bitmagnet | github-bitmagnet.md |
| https://api.github.com/repos/bitmagnet-io/bitmagnet/releases/latest | github-bitmagnet.md |
| https://github.com/bitmagnet-io/bitmagnet | github-bitmagnet.md (repo root, covered by API) |
| https://github.com/bitmagnet-io/bitmagnet/blob/e31b30d7351c269dc801876f92ebc59d31fee545/Dockerfile | github-bitmagnet.md (via pinned raw URL) |
| https://raw.githubusercontent.com/bitmagnet-io/bitmagnet/e31b30d7351c269dc801876f92ebc59d31fee545/Dockerfile | github-bitmagnet.md |
| https://bitmagnet.io | bitmagnet-docs.md |

Follow-up pages (same site): /setup/installation.html and /setup/configuration.html, merged into bitmagnet-docs.md.

Skipped: https://raw.githubusercontent.com/bitmagnet-io/bitmagnet/main/Dockerfile (not in list as REQUIRED, duplicate of the pinned commit, not fetched). No Docker Hub URL (GHCR image).

Failures: none.

## plan.md corrections
- None made. Plan version 0.10.0 matches the API latest release. Plan's ports 3333 and 3334/udp are still marked UNVERIFIED in plan, but the docs (compose example) and the chart confirm 3333 tcp and 3334 tcp+udp; plan left unchanged (status note, not a factual error).
- Plan's `POSTGRES_*` env names: docs compose example uses POSTGRES_HOST, POSTGRES_PASSWORD, POSTGRES_DB (and the chart uses POSTGRES_NAME/USER/PASSWORD/HOST); not a clear conflict, left unchanged.
