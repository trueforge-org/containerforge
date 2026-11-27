# Fossil SCM: download page and changes

Source URL(s):
- https://fossil-scm.org/home/uv/download.html (HTTP 200, fetched 2026-11-27)
- https://fossil-scm.org/home/doc/trunk/www/changes.wiki (HTTP 200, fetched 2026-11-27; no version heading matched in grep)
- https://fossil-scm.org (HTTP 302 redirect, not followed)

## Download
- Source tarball listed: `fossil-src-2.23.tar.gz` (the latest stable on the page at fetch time).
- URL pattern from the upstream Dockerfile: `https://www.fossil-scm.org/home/uv/fossil-src-<ver>.tar.gz`.

## Version naming
- Source tarball: `fossil-src-<ver>.tar.gz` (plain version, no `v`).
- Upstream Dockerfile pins 2.15.1 (chart appVersion). The page lists 2.23.

## Licence
- Not fetched in this run. Plan notes the licence is UNVERIFIED.
