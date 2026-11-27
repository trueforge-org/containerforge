# Docker Hub: xanderstrike/goplaxt

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/xanderstrike/goplaxt/
- https://hub.docker.com/v2/repositories/xanderstrike/goplaxt/tags?page_size=10
- Fetched 2026-11-27

## What it is
- Namespace `xanderstrike`, name `goplaxt`. No description.
- Pull count 2,202,012; star count 4. Last repo update 2024-11-13.
- Full description: Plex webhook to Trakt scrobbler (Go rewrite). Upstream says active development ended (Trakt offers official Plex webhooks); PRs still merged. Self-hosting needs a Trakt API app (redirect `<access URI>/authorize`), env vars TRAKT_ID, TRAKT_SECRET, ALLOWED_HOSTNAMES, keystore volume at `/app/keystore`, port 8000. Use tag `latest-arm7` for ARM devices. License MIT.

## Tags (3 total)
| Tag | last_updated (UTC) | Architectures |
| --- | --- | --- |
| latest-arm7 | 2024-11-13 00:14:47 | amd64 (per listing) |
| latest | 2024-11-13 00:14:40 | amd64 |
| staging | 2021-09-09 | amd64 |

## Version/asset naming
- Mutable tags only (`latest`, `latest-arm7`, `staging`); no semver tags.

## Gotchas
- `latest-arm7` is listed as amd64 only, despite its name; treat as unverified for ARM.
- Chart pins `latest` by digest (see truecharts-plaxt.md).
