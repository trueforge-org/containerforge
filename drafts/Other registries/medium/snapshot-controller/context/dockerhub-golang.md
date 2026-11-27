# Docker Hub library/golang (base-image reference)

Source URL(s): https://hub.docker.com/v2/repositories/library/golang/ and /tags?page_size=10 (fetched 2026-11-27 via https://registry.hub.docker.com/v2/... ; hub.docker.com itself returned DNS EAI_AGAIN)

## Repo facts
- Official image, maintained by docker-library (github.com/docker-library/golang).
- last_updated 2026-11-24, pull_count 2808449227, star_count 5125.
- Description: "Go (golang) is a general purpose, higher-level, imperative programming language."

## Tags seen (page_size=10)
| Tag | Last updated |
| --- | --- |
| latest, trixie | 2026-11-24 |
| bookworm | 2026-11-24 |
| 1.27.4-trixie | 2026-11-24 |
| tip, tip-trixie, tip-bookworm, tip-20261122* | 2026-11-24 |

- Full description lists Go 1.27.4 and 1.26.11 variants: `-trixie`, `-bookworm`, `-alpine3.24`, `-alpine3.23`, Windows servercore/nanoserver ltsc2025/ltsc2022.
- Total tag count reported: 5155.

## Gotchas
- Plan uses this only as a build-stage base reference; pin a specific `1.x.y-<distro>` tag rather than `latest`.
