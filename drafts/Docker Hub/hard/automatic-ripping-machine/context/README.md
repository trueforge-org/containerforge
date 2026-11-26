# automatic-ripping-machine context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/automatic-ripping-machine/automatic-ripping-machine (Dockerfile @ a380622, README, releases/latest, wiki) | github-automatic-ripping-machine-automatic-ripping-machine.md |
| https://github.com/automatic-ripping-machine/automatic-ripping-machine (README on main) | github-automatic-ripping-machine-raw-readme.md |
| https://hub.docker.com/r/automaticrippingmachine/automatic-ripping-machine | dockerhub-automaticrippingmachine-automatic-ripping-machine.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/automatic-ripping-machine | truecharts-automatic-ripping-machine.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... : not in this draft (none listed); forgetool schema URLs not referenced by this app's draft.
- https://github.com/trueforge-org/containerforge/tree/main/apps/{python,ubuntu}: ContainerForge base-app links.
- https://github.com/automatic-ripping-machine/automatic-ripping-machine/archive/refs/tags/${VERSION}.tar.gz: direct source archive download, pattern recorded.
- https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/HEAD/requirements.txt: moving HEAD file. Not fetched in this run; plan.md cites it as the Python dependency source (unverified here).
- `automaticrippingmachine/arm-dependencies` (named image base in Dockerfile): image ref, not a web page; its contents were not fetched.
- `ghcr.io/trueforge-org/*`, `docker.io/automaticrippingmachine/*`: image refs.
- `/dev/srN`, `/home/arm`, `/etc/arm/config`, `admin/password`: paths and placeholders, not URLs.

## Fetch failures
- Release asset names at https://github.com/automatic-ripping-machine/automatic-ripping-machine/releases/latest did not load (4 assets reported).
- Wiki `docker` page (run command, env, device flags, privileged, default login) is not in the wiki index fetched; not separately fetched (wiki index page shows the link as `docker`; not retried).

## plan.md corrections
- plan.md section 1 Version: `2.24.4` (published 3 Oct) -> `2.25.0` (latest GitHub release, 25 Nov, commit d9b80ce; chart pins `2.25.0`). Replaced in all 4 places (section 1 table, bake VERSION default, and the two build/test commands). Sources: github-automatic-ripping-machine-automatic-ripping-machine.md, truecharts-automatic-ripping-machine.md.

## Unverified (not changed in plan.md)
- plan.md section 1 `ARM_UID`/`ARM_GID`/`TZ` as wiki env: chart confirms ARM_UID and ARM_GID; TZ not seen.
- plan.md section 1 "default login admin/password per wiki": Hub page says a default admin login is documented but the wiki page was not fetched.
- plan.md section 1 "runs as root": chart runAsUser 0 confirms root for the chart; Dockerfile sets no USER.
- Draft copy-from `2.24.4`: Hub page does not list version tags, so it cannot be checked against the registry.
