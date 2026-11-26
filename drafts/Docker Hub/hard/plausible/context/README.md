# Context index: plausible

| Source URL | File |
| --- | --- |
| https://github.com/plausible/analytics/blob/0621fc0a77cc50add00baddbdd59f378324da483/Dockerfile | analytics-dockerfile.md |
| https://github.com/plausible/analytics (README via raw) | analytics-readme.md |
| https://github.com/plausible/hosting (README via raw) | hosting-ce-summary.md |
| https://raw.githubusercontent.com/plausible/community-edition/v3.2.2/compose.yml (follow-up) | ce-compose-v3.2.2.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plausible (values via raw) | truecharts-chart-values.md |
| https://hub.docker.com/r/plausible/analytics | dockerhub-plausible-analytics.md |
| https://plausible.io | plausible-io-docs-and-site.md |
| https://plausible.io/docs | plausible-io-docs-and-site.md |
| https://plausible.io/docs/self-hosting | plausible-io-docs-and-site.md (no install content) |

Skipped categories: none (no CLA, forgetool, containerforge, templated, binary or image-ref URLs in the list).

## Failures
- https://plausible.io/docs/self-hosting: no install/env details on page (install taken from community-edition repo)

## plan.md corrections
- None applied. Unverified conflicts (not applied): TrueCharts chart pins plausible/analytics:v2.0.0 while the CE Docker setup is v3.2.2 (ghcr.io/plausible/community-edition:v3.2.2, with postgres:16 and clickhouse 24.12). Plan not checked against this. Upstream Dockerfile pins alpine 3.18 / Elixir 1.14.3 at the pinned commit.
