# anonaddy context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/anonaddy/docker (Dockerfile @ e3f8bd3, README) | github-anonaddy-docker.md |
| https://github.com/anonaddy/anonaddy (README, composer.json @ v1.7.4, release v1.7.4) | github-anonaddy-anonaddy.md |
| https://addy.io/help/ and https://addy.io/ | addy-io-help.md |
| https://hub.docker.com/r/anonaddy/anonaddy | dockerhub-anonaddy-anonaddy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anonaddy | truecharts-anonaddy.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (2 schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz: direct source archive download. Naming pattern recorded in github-anonaddy-anonaddy.md.
- http://localhost:8000 and https://addy-sh.test: localhost and build-time placeholder URL (used as APP_URL during the npm build in the wrapper Dockerfile).
- `ghcr.io/trueforge-org/*`, `docker.io/anonaddy/*`: image refs, not web pages.

## Fetch failures
- Release asset list at https://github.com/anonaddy/anonaddy/releases/tag/v1.7.4 did not load (2 assets reported). Names unknown.

## plan.md corrections
None made. Checked against sources: version 1.7.4, licence AGPL-3.0-or-later, PHP ^8.3, ports 8000/25/11334, VOLUME /data, env vars list: all consistent.

## Unverified (not changed in plan.md)
- plan.md section 1 says the wrapper `anonaddy/docker` is MIT: licence not stated in fetched text.
- plan.md section 4 "PHP 8.5 composer lock acceptance": upstream tests PHP 8.4 per wrapper; no PHP 8.5 evidence fetched.
- Docker Hub tag `1.7.4` not listed on the Hub page (only `latest`). Digest matches the chart's pinned digest prefix.
- Upstream s6 service definitions (rootfs) not fetched.
