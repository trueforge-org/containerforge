# pi-hole/FTL release v6.9 (partial)

**Source URL(s):** https://github.com/pi-hole/FTL/releases/tag/v6.9 (HTML, alternative after API 403) · fetched 2026-11-27

## Status
- Only the release description meta tag was readable: security fixes list.
- GHSA-pj9m-9623-2g75 (High, CVSS 7.2): a quote in `files.gravity` or `files.database` ended the SQL string.
- Asset names and tag not extracted. Dockerfile implies asset naming `pihole-FTL-<arch>` (amd64, arm64, armv6, armv7, 386, riscv64).

## Gotchas
- Release API (api.github.com/repos/pi-hole/FTL/releases/tags/v6.9) returned 403 rate limit; not retried.
