# Docker Hub library/golang

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/library/golang/
- https://hub.docker.com/v2/repositories/library/golang/tags?page_size=10
- Fetched 2026-11-26

## What it is
Official Go image (docker-library/golang). Active; last_updated 2026-11-24. Tags total 5155.

## Tags (from repo description)
- Simple tags: `1.27.4-trixie`, `1.27-trixie`, `1-trixie`, `trixie`.
- `1.27.4-bookworm`, `1.27-bookworm`, `1-bookworm`, `bookworm`.
- `1.27.4-alpine3.24`, `1.27-alpine3.24`, `1-alpine3.24`, `alpine3.24`, `1.27.4-alpine`, `1.27-alpine`, `1-alpine`, `alpine`.
- `1.27.4-alpine3.23`, `1.27-alpine3.23`, `1-alpine3.23`, `alpine3.23`.
- Windows: `1.27.4-windowsservercore-ltsc2025`, `...-ltsc2022`.

## Arch (tag list)
- amd64, ppc64le, 386, s390x, arm/v7, arm64/v8, riscv64, plus others per tag.

## Gotchas
- `alpine` tag currently resolves to alpine3.24 (go 1.27.4). Miniflux Dockerfile pins `golang:alpine3.23`, which is a separate tag.
