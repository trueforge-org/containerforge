# Docker Hub library/alpine

Source URL(s) (fetched 2026-11-27, JSON API):
- https://hub.docker.com/v2/repositories/library/alpine/
- https://hub.docker.com/v2/repositories/library/alpine/tags?page_size=10

## What it is
Official Alpine Linux base image. Description: minimal image based on Alpine Linux, ~5 MB.

## Repo facts
- namespace: library, name: alpine
- repo last_updated: 2026-11-08T14:24:49Z
- pull_count ~12.6e9, star_count 11586
- tag count reported: 232

## Recent tags (page_size=10)
| Tag | last_updated | Archs (first 6 listed) |
| --- | --- | --- |
| latest | 2026-11-08 | amd64, ppc64le, 386, s390x, arm, arm64 |
| 3.24.4 | 2026-11-08 | same |
| 3.24 | 2026-11-08 | same |
| 3.23.8 | 2026-11-08 | same |
| 3.23 | 2026-11-08 | same |
| 3.22.8 | 2026-11-08 | same |
| 3.22 | 2026-11-08 | same |
| 3.21.10 | 2026-11-08 | same |
| 3.21 | 2026-11-08 | same |
| 3 | 2026-11-08 | same |

## Relevance
- Chart uses `docker.io/library/alpine:3.24@sha256:f59abe...` for the init container (see truecharts-dispatcharr-values.md).
- Tag `3.24` exists with multi-arch manifests (amd64, arm64, arm, 386, ppc64le, s390x).

## Gotchas
- Digest of tag 3.24 not verified against the chart pin in this run.
