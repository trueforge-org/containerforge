# aurora-files context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/afterlogic/docker-aurora-files (Dockerfile, afterlogic.php, config/nginx.conf) | github-afterlogic-docker-aurora-files.md |
| https://github.com/afterlogic/aurora-files (README, VERSION, releases) | github-afterlogic-aurora-files.md |
| https://afterlogic.com/docs | afterlogic-docs-index.md |
| https://hub.docker.com/r/afterlogic/docker-aurora-files | dockerhub-afterlogic-docker-aurora-files.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/aurora-files | truecharts-aurora-files.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (2 schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://afterlogic.org/download/aurora-files.zip: direct archive download (unversioned zip). Recorded in the Dockerfile summary; not downloaded.
- https://github.com/afterlogic/aurora-files/archive/latest.zip (named in the README install steps): direct archive, not fetched.
- https://github.com/afterlogic/aurora-files/releases (draft Application binary link): fetched as a repo page, see github-afterlogic-aurora-files.md.
- https://github.com/afterlogic/docker-aurora-files/blob/master/Dockerfile: fetched (raw) in the wrapper summary.
- `ghcr.io/trueforge-org/*` and `docker.io/afterlogic/*` image refs: not web pages.
- http://127.0.0.1/fpm-ping: localhost.

## Fetch failures
- Release asset list on https://github.com/afterlogic/aurora-files/releases did not load (2 assets per release). Names unknown.

## plan.md corrections
- plan.md section 1, Renovate row: the claim "the repo's Releases page is empty and I could not list its tags" is wrong. The releases page lists 10 releases and tags, with latest `9.3.1` (17 Mar, commit `8655ac5`). Edited the row to state this, source: github-afterlogic-aurora-files.md.

## Unverified (not changed in plan.md)
- plan.md section 1 License `AGPL-3.0-only` vs "or later": README says "AGPLv3" only. Left as UNVERIFIED in plan.md.
- Vendor zip terms on afterlogic.org: not read.
- Hub image license: README-level MIT claim on the Hub page conflicts with nothing in plan.md; the Hub page's MIT claim is for the wrapper repo, not the app.
