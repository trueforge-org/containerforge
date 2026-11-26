# Docker Hub: xhofe/alist-aria2

**Source URL(s) + fetch date:** https://hub.docker.com/r/xhofe/alist-aria2 · fetched 2026-11-26

## What it is
xhofe/alist image with aria2 preinstalled. Description: "A file list program that supports multiple storage, powered by Gin and Solidjs."

## Install/build steps
`docker pull xhofe/alist-aria2`. Example run maps port 5244, mounts `/etc/alist` to `/opt/alist/data`, sets PUID, PGID and UMASK. Initial admin info via `docker exec -it alist ./alist admin`.

## Version/release info
- Only `latest` listed on the page (size 43.1 MB, digest `sha256:573e8862f…`).
- No `v3.41.0` tag appears on the page.
- Page says last updated almost 2 years ago; 500K+ pulls, 152 stars.

## Arch support
Not listed on the page.

## License
AGPL-3.0 (per page).

## Contradictions with draft/plan
- draft.md `copy-from amd64` and `copy-from arm64` both say `xhofe/alist-aria2:v3.41.0`. The Docker Hub page does not list a `v3.41.0` tag (only `latest` visible). This is unverified against the registry tag list and should be rechecked before the copy-from value is used.
