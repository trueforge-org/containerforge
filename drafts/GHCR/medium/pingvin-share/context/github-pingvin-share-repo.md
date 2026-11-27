# Upstream: stonith404/pingvin-share (repo, LICENSE, README, release, docs site)

Source URL(s) + date:
- https://github.com/stonith404/pingvin-share (2026-11-27, HTML)
- https://raw.githubusercontent.com/stonith404/pingvin-share/main/LICENSE (2026-11-27)
- https://raw.githubusercontent.com/stonith404/pingvin-share/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/README.md (2026-11-27)
- https://api.github.com/repos/stonith404/pingvin-share/license: 403. Recovered with the LICENSE raw file above.
- https://api.github.com/repos/stonith404/pingvin-share/releases/latest: 403. Alternative https://github.com/stonith404/pingvin-share/releases/latest (HTML) -> "Release v1.13.0"
- https://github.com/stonith404/pingvin-share/releases/tag/v1.13.0: covered by the alternative above
- https://stonith404.github.io/pingvin-share: JS-rendered, only the title "Pingvin Share" came back. No docs text retrieved.

What it is: self-hosted file sharing (WeTransfer alternative). Frontend Next.js, backend NestJS/Prisma, Caddy reverse proxy.

License: BSD-2-Clause (LICENSE: "Copyright (c) 2022, Elias Schneider"). Repo page lists "BSD-2-Clause license".

Install (README, Docker recommended):
1. Download `docker-compose.yml`
2. `docker compose up -d`
3. Website on `http://localhost:3000`

docker-compose.yml (same commit):
| Item | Value |
| --- | --- |
| image | `stonith404/pingvin-share` (or ghcr.io) |
| ports | `3000:3000` |
| env | `TRUST_PROXY=false` |
| volumes | `./data:/opt/app/backend/data`, `./data/images:/opt/app/frontend/public/img` |
| optional | `./config.yaml:/opt/app/config.yaml` (config via file instead of UI) |
| optional | ClamAV integration (docs link, not fetched) |

Version: latest release `v1.13.0` (HTML, 2026-11-27). Chart appVersion matches.

Gotchas: docs site is client-rendered; config option names beyond those in compose and scripts were not retrieved.
