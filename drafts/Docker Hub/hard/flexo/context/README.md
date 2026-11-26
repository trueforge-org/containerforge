# Context for flexo

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/nroi/flexo | github-nroi-flexo.md |
| https://raw.githubusercontent.com/nroi/flexo/master/README.md | github-nroi-flexo.md (summary, not verbatim) |
| https://raw.githubusercontent.com/nroi/flexo/master/flexo/conf/flexo.toml | github-nroi-flexo.md (defaults table) |
| https://github.com/nroi/flexo/tags | github-nroi-flexo.md (version list) |
| https://github.com/nroi/flexo/wiki | github-nroi-flexo-wiki.md |
| https://github.com/nroi/flexo/wiki/Flexo-with-Docker | github-nroi-flexo-wiki.md (followed sub-page, env var list) |
| https://hub.docker.com/r/nroi/flexo | dockerhub-nroi-flexo.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flexo | truecharts-flexo.md |
| https://github.com/nroi/scruffy | github-nroi-scruffy.md (plan reference: cache purge dependency) |
| https://github.com/nroi/scruffy/tags | github-nroi-scruffy.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/nroi/flexo/archive/refs/tags/${VERSION}.tar.gz | contains `${`; auto-generated source tarball recorded in github-nroi-flexo.md |
| ghcr.io/trueforge-org/ubuntu (and @sha256 variant) | ghcr image ref, not a web page |
| docker.io/nroi/flexo:1.6.14 | image ref; covered by the Docker Hub page above |
| http://<host>:7878/..., http://flexo-probe:7878 | placeholder host (`<host>`) and probe container name |
| archlinux.org | bare host named in plan prose; the mirror status endpoint in upstream config (https://archlinux.org/mirrors/status/json/) is recorded in github-nroi-flexo.md, not fetched |
| https://aur.archlinux.org/packages/flexo-git/ | AUR packaging route, not a container build input |
| ./mirror_selection.md, flexo/terminology.md (linked from README) | not fetched; upstream config comments and wiki cover the settings |

## Fetch failures

- None hard. The wiki sidebar showed a loading-error banner; page content was still returned.
- Docker Hub page gives no architecture, volume, port or env data (not a failure; not on the page).

## plan.md corrections

- None made. Upstream facts match plan.md for version 1.6.14, tags-based renovate, MIT-free note, port 7878, env var names, and scruffy GPL-2.0.
- Contradiction (not edited, not a clear factual error): README says the first start runs latency tests for about 30 s and "serves no requests during that time". plan.md sections 8 and 11 assume a TCP probe on 7878 succeeds during startup. The 120 s timeout covers it, but the readiness wording should be checked.
- Verified values now available for plan.md's "UNVERIFIED" `[mirrors_auto]` defaults (for start.sh): `FLEXO_MIRRORS_AUTO_MAX_SCORE=2.5`, `FLEXO_MIRRORS_AUTO_NUM_MIRRORS=8`, `FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT=sort`, `FLEXO_MIRRORS_AUTO_TIMEOUT=350`, `FLEXO_REFRESH_LATENCY_TESTS_AFTER=8 days`, `FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES=[]`. Plan left as written (it asked for values to be copied at implementation time).

Unverified (not changed):
- Plan's claim that `/usr/bin/flexo_purge_cache` is a bash script in the repo root: README says "No purge script is mentioned"; not confirmed.
- Plan's claim that any `FLEXO_*` variable switches config to env-only mode: not stated in fetched sources.
- Plan's `scruffy` tag 0.2.0 vs Cargo.toml 0.1.0 mismatch: Cargo.toml not visible; tags 0.2.0 and 0.1.0 confirmed.
- Plan's `listen_ip_address` code default `0.0.0.0` when unset: not confirmed.
- 1.6.14 has no release object (inference from the tags page only).
- Chart probe path `/metrics`: exists in chart, not confirmed upstream.
- Plan's `libssl-dev` system build vs README's vendored openssl hint: not decided here.
