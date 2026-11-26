# GitHub joplin releases (latest + pinned tags)

## Source URL(s) + date
- https://api.github.com/repos/laurent22/joplin/releases/latest (2026-11-26)
- Covers, without separate fetch: https://github.com/laurent22/joplin/releases/tag/v3.7.24, /releases/tag/v3.7.6, /releases/expanded_assets/v3.7.24.

## Version/asset naming
- Latest: tag `v3.7.24`, published 2026-11-19T17:20:16Z.
- Assets (all desktop/client, no server tarball): `Joplin-3.7.24-arm64.DMG`, `Joplin-3.7.24-arm64.zip`, `Joplin-3.7.24-arm64.pkg`, `Joplin-3.7.24.AppImage` (+ `.sha512`), `Joplin-3.7.24.deb`, `Joplin-3.7.24.dmg`, `Joplin-3.7.24.pkg`, `Joplin-Setup-3.7.24.exe`, `JoplinPortable.exe`, `latest-linux.yml`, `latest-mac.yml`, `latest-mac-arm64.yml`, `latest.yml` (+ blockmap files).
- Source archive (tag): `https://github.com/laurent22/joplin/archive/refs/tags/v<version>.tar.gz` (not fetched; plan.md marks UNVERIFIED).

## Gotchas
- No server asset on releases. Server images must be built from the tag source.
- Tag v3.7.6 (used by TrueCharts chart and Docker Hub 3.7.6) is older than latest v3.7.24.
- Not fetched: releases/tag HTML pages (budget: API used instead). joplinapp.org/help and repo tree/dev/packages/server were not fetched (generic docs, covered by Dockerfile and Docker Hub text).
