# Docker Hub: library/golang (build base)

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/library/golang/ (2026-11-27, JSON)
- https://hub.docker.com/v2/repositories/library/golang/tags?page_size=10 (2026-11-27, JSON, first page only)

What it is: official Docker Library image "golang" (Go language). Pull count 2,808,429,961. Last updated 2026-11-24. Maintained at github.com/docker-library/golang.

Relevance: used only as the build stage of the upstream nullserv Dockerfile (`FROM golang:alpine AS build-env`). Not the runtime image.

Tags seen on first page (2026-11-27, newest first, all last updated 2026-11-24):
- latest, trixie, tip-trixie, tip-bookworm, tip-20261122-trixie, tip-20261122-bookworm, tip-20261122, tip, bookworm, 1.27.4-trixie

Architectures on these tags: 386, amd64, arm, arm64, ppc64le, s390x, plus riscv64 on trixie/latest/tip; `unknown` also listed (attestations).

Gotchas:
- The `alpine` tag used by the upstream Dockerfile is not on the first page (10 results); its existence was not verified here.
- Docker Hub `tags` list is paged (count 5155).
