# binhex/documentation (index + General Docker FAQ)

Source URL(s): https://github.com/binhex/documentation (WebFetch); https://raw.githubusercontent.com/binhex/documentation/master/docker/faq/general.md (fetched 2026-11-27)

## Repo
- Index of guides/FAQs for binhex Docker images. License GPL-3.0. Folder: docker/ (guides/, faq/).
- Index page does not state env vars, ports, /config path, PUID/PGID or healthcheck.

## General Docker FAQ (key facts)
- /config container volume: application configuration (ini, DBs, cache).
- /data: downloaded data. /media: media library access for indexers.
- Volume mapping: container path (root inside container) to host path. Configure apps using container path.
- Port mappings: do NOT change container port set in image.
- Networking: bridge (default) vs host network.
