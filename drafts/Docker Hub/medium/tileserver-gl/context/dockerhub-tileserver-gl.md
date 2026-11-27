# Docker Hub maptiler/tileserver-gl

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/maptiler/tileserver-gl/
- https://hub.docker.com/v2/repositories/maptiler/tileserver-gl/tags?page_size=10
- Fetched 2026-11-27

## What it is
- name `tileserver-gl`, namespace `maptiler`, description "MapTiler TileServer GL"
- last_updated 2026-10-23; pull_count 7143468; star_count 20; count 160 tags
- Full description: vector and raster maps with GL styles; server-side rendering via Mapbox GL Native; Get Started section.

## Tags (page_size=10)
| tag | last_updated | arch |
| --- | --- | --- |
| latest | 2026-10-23 | amd64, arm64 |
| v5.7.0 | 2026-10-23 | amd64, arm64 |
| v5.7.0-arm64 | 2026-10-23 | arm64 |
| v5.7.0-amd64 | 2026-10-23 | amd64 |
| v5.7.0-pre.1 | 2026-08-31 | amd64, arm64 |
| next | 2026-08-31 | amd64, arm64 |
| v5.7.0-pre.1-amd64 | 2026-08-31 | amd64 |
| v5.7.0-pre.1-arm64 | 2026-08-31 | arm64 |
| v5.7.0-pre.0 | 2026-05-28 | amd64, arm64 |
| v5.7.0-pre.0-amd64 | 2026-05-28 | amd64 |

- Chart pins `v5.7.0` (multi-arch manifest, amd64 + arm64).

## Docker Hub README run example
- `docker run --rm -it -v $(pwd):/data -p 8080:80 maptiler/tileserver-gl`
- NOTE: the example maps host 8080 to container port **80**. Upstream Dockerfile EXPOSEs 8080 and docs say the default port is 8080. Treat the `:80` in the example as stale.

## Gotchas
- Chart pins the digest of `v5.7.0`; `latest` and `v5.7.0` share the same last_updated date.
