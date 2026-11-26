# baserow context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/baserow/baserow (README, deploy/all-in-one/Dockerfile @ d897b90, releases/tag/2.4.3, premium/LICENSE) | github-baserow-baserow.md |
| https://baserow.io/docs/index | baserow-docs-index.md |
| https://hub.docker.com/r/baserow/baserow | dockerhub-baserow-baserow.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baserow | truecharts-baserow.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://github.com/trueforge-org/containerforge/tree/main/apps/{python,ubuntu}: ContainerForge base-app links.
- https://github.com/baserow/baserow/archive/refs/tags/${VERSION}.tar.gz: direct source archive download, pattern recorded.
- https://github.com/baserow/baserow/blob/HEAD/embeddings/requirements.txt: fetch failed (see below), not a download.
- http://localhost:8080: localhost.
- `ghcr.io/trueforge-org/*`, `docker.io/baserow/*`, `baserow/backend`, `baserow/web-frontend`, `baserow/baserow-pgautoupgrade`: image refs.

## Fetch failures
- `embeddings/requirements.txt` at d897b90 (raw): HTTP 404. Retried on `master` (raw): HTTP 404. Not summarised. plan.md's list of embeddings deps is unverified.
- https://gitlab.com/bramw/baserow: loaded; it is the old location that says the project moved to GitHub. Recorded in github-baserow-baserow.md.
- Release asset names at https://github.com/baserow/baserow/releases/tag/2.4.3 did not load (2 assets).

## plan.md corrections
None made. Checked: version 2.4.3 (14 Nov), Dockerfile base/Caddy/supervisor/entrypoint/ports 80 and 25, `/baserow/data`, chart postgres/valkey: consistent.

## Unverified (not changed in plan.md)
- plan.md section 1 licence row: premium/LICENSE is the Baserow Premium Edition licence (proprietary), and the all-in-one image copies premium and enterprise backend code. This settles the "UNVERIFIED" part; the decision on bake LICENSE and whether to remove those dirs is still open in plan.md.
- plan.md section 1 env vars and `.secret` path: Baserow docs pages not fetched.
- plan.md section 3 "Python 3.14 vs 3.15 compatibility": not checked.
