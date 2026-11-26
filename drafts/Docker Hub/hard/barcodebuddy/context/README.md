# barcodebuddy context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/Forceu/barcodebuddy-docker (Dockerfile @ 527c3c6) | github-forceu-barcodebuddy-docker.md |
| https://github.com/Forceu/barcodebuddy (README, release v1.9.0.1, LICENSE.md) | github-forceu-barcodebuddy.md |
| https://hub.docker.com/r/f0rc3/barcodebuddy | dockerhub-f0rc3-barcodebuddy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/barcodebuddy | truecharts-barcodebuddy.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://github.com/Forceu/barcodebuddy/archive/refs/tags/v${VERSION}.tar.gz: direct source archive download; pattern recorded.
- http://127.0.0.1:8080/; (localhost).
- `ghcr.io/trueforge-org/*`, `docker.io/f0rc3/barcodebuddy`: image refs.

## Fetch failures
- https://github.com/Forceu/barcodebuddy/blob/master/LICENSE: HTTP 404. Retried with the raw `LICENSE.md` path (found; see github-forceu-barcodebuddy.md).
- Release asset names at https://github.com/Forceu/barcodebuddy/releases/tag/v1.9.0.1 did not load.

## plan.md corrections
None made. Checked: version 1.9.0.1 (25 Sep), Dockerfile (alpine 3.24, php85, golang:1.27 supervisor), ports 80/443, `/config` with `/data` symlink, env vars (none declared): consistent. Licence and asset note left as unverified (below).

## Unverified (not changed in plan.md)
- plan.md License row: `LICENSE.md` is AGPL v3 text and the README says "AGPL3+". Whether to write `AGPL-3.0-only` or `AGPL-3.0-or-later` still needs the file headers checked.
- plan.md Download row ("no uploaded assets"): release shows "2 assets" (names not loaded), likely the auto source archives.
- Input-grabber env var names from supervisor/environment (plan.md): not fetched.
