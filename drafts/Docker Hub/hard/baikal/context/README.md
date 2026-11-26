# baikal context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/ckulka/baikal-docker (nginx.dockerfile @ 06c5398) | github-ckulka-baikal-docker.md |
| https://github.com/sabre-io/Baikal (README, composer.json @ 0.13.0, releases/latest) | github-sabre-io-baikal.md |
| https://sabre.io/baikal/ and https://sabre.io/baikal/install/ | sabre-io-baikal-docs.md |
| https://hub.docker.com/r/ckulka/baikal | dockerhub-ckulka-baikal.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baikal | truecharts-baikal.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip and `.../0.13.0/baikal-0.13.0.zip`: direct archive downloads. Naming pattern recorded in github-sabre-io-baikal.md.
- https://github.com/ckulka/baikal-docker/blob/<sha>/nginx.dockerfile: fetched as raw (see wrapper summary).
- http://127.0.0.1:8080/: localhost.
- `include/.dockerignore` (repo path named in the plan): local repo file, not a web source.
- https://sabre.io/baikal/docker-install/ and other sabre.io sub-pages: linked from the intro, not fetched (not install-critical for this port).
- `ghcr.io/trueforge-org/*`, `docker.io/ckulka/baikal`: image refs.

## Fetch failures
- Release asset list at https://github.com/sabre-io/Baikal/releases/latest did not load (3 assets). Names unconfirmed in this fetch; plan.md cites the zip asset from the GitHub API.

## plan.md corrections
None made. Checked: version 0.13.0 (19 Oct), GPL-3.0-only, PHP ^8.2 with dom/pdo/zlib, wrapper structure, port 80, BAIKAL_SKIP_CHOWN, volume paths: all consistent with sources.

## Unverified (not changed in plan.md)
- plan.md section 1 checksum: release assets did not load; still UNVERIFIED.
- plan.md section 1 `config/baikal.yaml`: not confirmed by the install page.
- Hub shows image tags only up to 0.10.1; no 0.13.0 image exists to copy from, which fits "copy-from" being `no` or a rebuild.
- Wrapper uses PHP 8.1 and Baikal 0.10.1; Baikal 0.13.0 needs PHP ^8.2 (conflict noted in github-ckulka-baikal-docker.md).
