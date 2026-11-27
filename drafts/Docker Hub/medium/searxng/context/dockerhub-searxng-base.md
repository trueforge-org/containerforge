# Docker Hub: searxng/base

Source URL(s): https://hub.docker.com/v2/repositories/searxng/base/ and .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- Base image `searxng/base`, ~24K pulls, no description, not automated. Built from github.com/searxng/base (Dockerfile at raw main).
- Total tags: 3.

## Tags
| Tag | Last updated | Platforms | Purpose |
| --- | --- | --- | --- |
| searxng | 2026-11-27 | amd64, arm64, arm | final runtime base (`FROM docker.io/searxng/base:searxng` in upstream Dockerfile) |
| core | 2026-11-27 | amd64, arm64, arm | core rootfs (no searxng packages) |
| searxng-builder | 2026-11-27 | amd64, arm64, arm | builder base (`FROM docker.io/searxng/base:searxng-builder`) |

## Gotchas
- Base is Void Linux (xbps) built on Alpine bootstrap; see github-searxng-dockerfile.md for the base Dockerfile stages.
