# Docker Hub: lmscommunity/lyrionmusicserver

Source URL(s), fetched 2026-11-27:
- https://hub.docker.com/v2/repositories/lmscommunity/lyrionmusicserver/
- https://hub.docker.com/v2/repositories/lmscommunity/lyrionmusicserver/tags?page_size=10

## Repository
- Namespace `lmscommunity`, name `lyrionmusicserver`, public, active, not automated, no source link
- Description: official image from the LMS community for Lyrion Music Server
- Formerly named `logitechmediaserver`
- Pull count 2,841,162; stars 39
- Registered 2024-04-01; last modified 2026-06-17; last updated 2026-11-27
- Media type: OCI image index; immutable tags disabled
- Storage ~56.0 GB

## Tags (page 1, 8 results; summarizer note: API reported count 18)
| Tag | Last updated | Full size | Arch / os / size |
| --- | --- | --- | --- |
| 9.1.2-stable | 2026-11-27 | 71641245 | amd64 / arm64 / arm(v7) (linux) |
| stable | 2026-11-27 | 71641245 | amd64 / arm64 / arm(v7) |
| 9.1.2 | 2026-11-27 | 71641245 | amd64 / arm64 / arm(v7) |
| 9.2.0-dev | 2026-11-26 | 74917872 | amd64 / arm64 / arm(v7) |
| dev | 2026-11-26 | 74917872 | amd64 / arm64 / arm(v7) |
| 9.2.0 | 2026-11-26 | 74917872 | amd64 / arm64 / arm(v7) |
| latest | 2026-06-17 | 71799795 | amd64 / arm64 / arm(v7) + 3 unknown/unknown attestation entries |
| rc | 2026-06-17 | 71799795 | same as latest |
| 9.1.1 | 2026-06-17 | 71799795 | same as latest |
| 9.1.1-stable | 2026-05-27 | 71793837 | amd64 / arm64 / arm(v7) + 3 unknown entries |

- Per-arch sizes for 9.2.0: amd64 81442916, arm64 82187720, arm(v7) 74917872.
- Per-arch sizes for 9.1.2: amd64 78901281, arm64 78556061, arm(v7) 71641245.

## Tag meanings (from repo description)
- `latest` = newest release, v9.1.1
- `stable` = bug-fix branch, v9.1.2
- `dev` = development build, v9.2.0

## Run config (from repo description)
- Volumes: `/config` (rw), `/music` (ro), `/playlist` (rw), plus ro `/etc/localtime` and `/etc/timezone`
- Ports: 9000/tcp (HTTP), 9090/tcp (CLI), 3483/tcp, 3483/udp
- Ports 9000 and 9090 must map 1:1

## Gotchas
- Tag pinned by TrueCharts is 9.2.0 (dev channel, not the `latest`=9.1.1 tag). Confirm this is intended before any bake/Dockerfile version alignment.
- The tag list above is the summarizer's read of page 1 only; the API reports 18 tags total.
