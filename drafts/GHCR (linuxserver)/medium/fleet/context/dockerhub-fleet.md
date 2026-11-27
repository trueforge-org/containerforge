# Docker Hub: linuxserver/fleet

Source URLs (fetched 2026-11-27):
- https://hub.docker.com/v2/repositories/linuxserver/fleet/
- https://hub.docker.com/v2/repositories/linuxserver/fleet/tags?page_size=10

## Repository
- Namespace/name: linuxserver/fleet, type image, status active, not private.
- **DEPRECATED** as of 03.06.25: the image is no longer supported or updated (LSIO notice).
- Last updated 2025-06-03. Registered 2019-04-04.
- Stars 26, pulls ~548k. No license field. Source: github.com/linuxserver/docker-fleet and github.com/linuxserver/fleet.
- Categories: Security; Integration & delivery; Operating systems.

## Usage (from README)
- Web UI on port 8080.
- DATABASE auth: create first user at `/setup`, then log in at `/login`. Restart removes the setup page.
- Env: PUID, PGID, TZ, authentication type (DATABASE or PROPERTIES), JDBC DB URL, DB username and password, optional admin secret.
- Volume `/config`. Supports read-only rootfs and non-root, FILE__ prefix for secrets, UMASK, Docker Mods.
- Changelog: Alpine rebases to 3.21 (Dec 2024); Log4j mitigations (Dec 2021); initial release 01.04.19.

## Tags (page 1 of 851)
| Tag | Last updated (UTC) | Size (bytes) | Arch |
| --- | --- | --- | --- |
| latest | 2025-06-03 | 0 (inactive) | none listed |
| 2.3.3 | 2025-06-03 | 82367784 | amd64, arm64 |
| version-2.3.3 | 2025-06-03 | 82367784 | amd64, arm64 |
| 2.3.3-ls212 | 2025-06-03 | 82367784 | amd64, arm64 |
| arm64v8-latest | 2025-06-03 | 0 (inactive) | none listed |
| amd64-latest | 2025-06-03 | 0 (inactive) | none listed |
| arm64v8-2.3.3 | 2025-06-03 | 82748289 | arm64 |
| amd64-2.3.3 | 2025-06-03 | 82367784 | amd64 |
| arm64v8-version-2.3.3 | 2025-06-03 | 82748289 | arm64 |
| arm64v8-2.3.3-ls212 | 2025-06-03 | 82748289 | arm64 |

## Arch
- amd64 and arm64 only. armhf not available.

## Gotchas
- Image is deprecated upstream (LSIO), so no new builds since 2025-06-03.
