# Context index: sourcegraph

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/values.yaml | truecharts-sourcegraph.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/Chart.yaml | truecharts-sourcegraph.md |
| https://hub.docker.com/v2/repositories/sourcegraph/server/ | dockerhub-sourcegraph.md |
| https://hub.docker.com/v2/repositories/sourcegraph/server/tags?page_size=10 | dockerhub-sourcegraph.md |
| https://sourcegraph.com/docs | sourcegraph-docs.md |
| https://github.com/sourcegraph/sourcegraph | sourcegraph-docs.md (failure recorded) |

Skipped categories: none.

Failures:
- https://github.com/sourcegraph/sourcegraph (HTTP 404).
- https://raw.githubusercontent.com/sourcegraph/sourcegraph/main/README.md (alternative, HTTP 404).

## plan.md corrections
None applied. Pinned tag, digest, amd64-only arch, and chart ports (7080, 2633, 3370) and data paths agree with fetched sources.

Unverified (not edited, no source fetched for these):
- plan.md line 18 (draft's 7443 and 3178 not in chart): consistent with chart values, no change.
- Env list, upstream Dockerfile and Postgres/Redis dependencies remain unverified (no source in this run).
