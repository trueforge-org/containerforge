# Context for flexo

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/nroi/flexo | github-nroi-flexo.md |
| https://raw.githubusercontent.com/nroi/flexo/master/README.md | github-nroi-flexo.md |
| https://raw.githubusercontent.com/nroi/flexo/master/flexo/conf/flexo.toml | github-nroi-flexo.md |
| https://github.com/nroi/flexo/tags | github-nroi-flexo.md |
| https://api.github.com/repos/nroi/flexo/releases/latest | github-nroi-flexo.md |
| https://github.com/nroi/flexo/wiki | github-nroi-flexo-wiki.md |
| https://github.com/nroi/flexo/wiki/Flexo-with-Docker | github-nroi-flexo-wiki.md |
| https://hub.docker.com/r/nroi/flexo | dockerhub-nroi-flexo.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flexo | truecharts-flexo.md |
| https://github.com/nroi/scruffy | github-nroi-scruffy.md |
| https://github.com/nroi/scruffy/tags | github-nroi-scruffy.md |

Skipped: CLA link, forgetool schema, containerforge apps/<base> links, templated `${VERSION}` source tarball, ghcr/docker image refs (`ghcr.io/trueforge-org/ubuntu`, `docker.io/nroi/flexo:1.6.14`), placeholder hosts (`<host>`, `flexo-probe`), bare host `archlinux.org`, AUR packaging page (`aur.archlinux.org/packages/flexo-git`, not a container input), and README-linked `mirror_selection.md` / `terminology.md` (not fetched).

## Fetch failures

- None hard. The wiki sidebar showed a loading banner; page content was still returned.

## plan.md corrections

- None made. Fetched facts agree with plan.md on version 1.6.14, renovate on tags, port 7878, scruffy GPL-2.0 and the env var names.
- Unverified conflict (not edited): README says the first start runs latency tests for about 30 s and serves no requests during that time. plan.md sections 8 and 11 assume the TCP probe on 7878 works during startup.
- Verified (not edited, plan marked UNVERIFIED): `[mirrors_auto]` defaults `max_score=2.5`, `num_mirrors=8`, `mirrors_random_or_sort=sort`, `timeout=350`, `refresh_latency_tests_after=8 days`, `allowed_countries=[]`.
- Unverified (not edited): `/usr/bin/flexo_purge_cache` as a bash script in the repo root (README says no purge script is mentioned).
- Unverified (not edited): any `FLEXO_*` variable switches config to env-only mode (not stated in sources).
- Unverified (not edited): scruffy Cargo.toml version 0.1.0 vs tag 0.2.0 (tags confirmed, Cargo.toml not visible).
- Unverified (not edited): 1.6.14 has no release object (inferred; latest GitHub release is 1.6.10 with no assets).
- Unverified (not edited): chart probe path `/metrics` exists upstream.
