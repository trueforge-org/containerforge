# Context: fluttercoin-wallet

Fetched 2026-11-27. Sources from urls.txt.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluttercoin-wallet/values.yaml | truecharts-fluttercoin-wallet.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluttercoin-wallet/Chart.yaml | truecharts-fluttercoin-wallet.md |
| https://raw.githubusercontent.com/ich777/docker-fluttercoin/master/Dockerfile | ich777-docker-fluttercoin.md |
| https://github.com/ich777/docker-fluttercoin/blob/master/Dockerfile | ich777-docker-fluttercoin.md (same file) |
| https://raw.githubusercontent.com/ich777/docker-fluttercoin/master/scripts/start.sh | ich777-docker-fluttercoin.md (followed) |
| https://raw.githubusercontent.com/ofeefee/fluttercoin/master/README.md | github-ofeefee-fluttercoin.md |
| https://github.com/ofeefee/fluttercoin | github-ofeefee-fluttercoin.md (repo root, README used) |

## Skipped
- Templated/boilerplate: none of note.
- Image refs: https://ghcr.io/ich777/fluttercoin (in chart sources, not in urls).
- Dockerfile blob variant duplicates raw URL.

## Failures
- https://api.github.com/repos/ofeefee/fluttercoin/releases/latest: HTTP 403 (rate limit). Alternative https://github.com/ofeefee/fluttercoin/releases/latest returned HTML with no extractable tag; no release data recorded.
- https://api.github.com/repos/ofeefee/fluttercoin/license: HTTP 403 (rate limit). Alternative https://raw.githubusercontent.com/ofeefee/fluttercoin/master/LICENSE: HTTP 404.
- https://fluttercoin.me: not fetched (budget; info is in chart sources only).

## plan.md corrections
- none (not checked against plan.md; no conflicts proven).
