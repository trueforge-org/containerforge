# Docker Hub: nightscout/cgm-remote-monitor-travis

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/nightscout/cgm-remote-monitor-travis/ (2026-11-26)
- https://hub.docker.com/v2/repositories/nightscout/cgm-remote-monitor-travis/tags?page_size=10 (2026-11-26)

## What it is
- Repo type: image, status active, not automated, description: "*EXPERIMENTAL* ... still experimenting with build numbers and versioning."
- Full description: built automatically via Travis-CI; "this repository will be removed once the Docker builds have stabilised."
- pull_count 478852; last_updated 2021-01-01; last_modified 2024-10-16. Stars 5.
- Hub listing is stale: no push since 2021-01-01.

## Tags (top of list, page_size=10; count 48)
| Tag | last_updated | arch |
| --- | --- | --- |
| latest | 2020-12-27 | amd64 |
| 14.1.0 | 2021-01-01 | amd64 |
| latest_dev | 2020-12-30 | amd64 |
| 14.0.8 | 2020-12-13 | amd64 |
| 14.0.7 | 2020-11-15 | amd64 |
| 14.0.6 | 2020-11-14 | amd64 |
| 14.0.5 | 2020-09-28 | amd64 |
| 14.0.4 | 2020-09-27 | amd64 |
| 14.0.3 | 2020-09-22 | amd64 |
| 14.0.2 | 2020-09-16 | amd64 |

- `latest` digest sha256:3ace874753e834b9c9b8a242df67f86329b04a3a48584452ae45207bfbfdb271 (matches chart pin). Only amd64 seen in the top tags.
- Image size ~438 MB (latest).

## Gotchas
- Hub tags are 2020-2021 Travis builds, about 5 years older than the upstream GitHub Dockerfile (node:22-alpine, multi-stage). Upstream v15.x is not published to this repo.
- No version alignment with the GitHub release tags (v15.0.9).
