# Docker Hub yourselfhosted/slash

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/yourselfhosted/slash/
- https://hub.docker.com/v2/repositories/yourselfhosted/slash/tags?page_size=10
- Fetched 2026-11-27

## What it is
- name `slash`, namespace `yourselfhosted`
- Description: "An open source, self-hosted bookmarks and link sharing platform."
- last_updated 2026-08-24; pull_count 526630; star_count 5

## Tags (page_size=10, count 19)
| tag | last_updated | arch |
| --- | --- | --- |
| latest | 2024-10-21 | amd64, arm64, unknown, unknown |
| test | 2026-08-24 | amd64 |
| 1.0.0-rc.3 | 2026-08-23 | amd64, arm64 |
| 1.0.0-rc.2 | 2025-12-17 | amd64, arm64 |
| 1.0.0-rc.1 | 2025-05-07 | amd64, arm64 |
| 1.0.0-rc.0 | 2024-11-03 | amd64, arm64 |
| 0.5.3 | 2024-02-07 | amd64, arm64 |
| 0.5.2 | 2024-01-21 | amd64, arm64 |
| 0.5.1 | 2023-12-24 | amd64, arm64 |
| 0.5.0 | 2023-11-12 | amd64, arm64 |

Gotcha: `latest` (2024-10-21) is older than 1.0.0-rc.x tags; do not treat `latest` as current.

## Runtime (from upstream Dockerfile, see github-slash-dockerfile.md)
- EXPOSE 5231; VOLUME `/var/opt/slash`; ENV `SLASH_MODE=prod`, `SLASH_PORT=5231`, `TZ=UTC`
- ENTRYPOINT `["./slash"]`, WORKDIR `/usr/local/slash`
- Arch: amd64 + arm64 for rc and 0.5.x tags
