# GitHub bitmagnet-io/bitmagnet (repo, latest release, Dockerfile)

## Source URL(s) + date
- https://api.github.com/repos/bitmagnet-io/bitmagnet (fetched 2026-11-27)
- https://api.github.com/repos/bitmagnet-io/bitmagnet/releases/latest (fetched 2026-11-27)
- https://raw.githubusercontent.com/bitmagnet-io/bitmagnet/e31b30d7351c269dc801876f92ebc59d31fee545/Dockerfile (pinned commit, fetched 2026-11-27)

## What it is
- Repo: Go, 4480 stars at fetch time. License SPDX: MIT.
- Latest (non-prerelease) release from API: tag `v0.10.0`, published 2025-03-02T15:13:47Z.
- Chart image tag v0.10.1 is not the API "latest"; the plan records only `v0.10.1-beta.1` (prerelease) for 0.10.1.

## Release assets (v0.10.0, first 20 names shown by API)
- `bitmagnet_0.10.0_checksums.txt`
- Linux: `bitmagnet_0.10.0_linux_amd64.{apk,deb,rpm,pkg.tar.zst}`, `bitmagnet_0.10.0_linux_arm64.{apk,deb,rpm,tar.gz,pkg.tar.zst}`, `bitmagnet_0.10.0_linux_armv6.{apk,deb,rpm}`, `bitmagnet_0.10.0_linux_arm.tar.gz`, `bitmagnet_0.10.0_linux_x86_64.tar.gz` (name in list truncated at 20)
- Darwin: `bitmagnet_0.10.0_darwin_arm64.tar.gz`, `..._darwin_x86_64.tar.gz`; FreeBSD: `..._freebsd_x86_64.tar.gz`; Windows: `..._windows_x86_64.zip`

## Dockerfile (pinned commit e31b30d)
- Build stage: `FROM golang:1.23.6-alpine3.20 AS build`; apk add gcc musl-dev git; `COPY . /build`; `go build -ldflags "-s -w -X github.com/bitmagnet-io/bitmagnet/internal/version.GitTag=$(git describe --tags --always --dirty)"`
- Final stage: `FROM alpine:3.20`; apk add curl iproute2-ss; `COPY --from=build /build/bitmagnet /usr/bin/bitmagnet`
- `ENTRYPOINT ["bitmagnet"]`
- No USER, no EXPOSE, no VOLUME, no HEALTHCHECK.

## Gotchas
- Upstream image is musl (alpine), built from source in Dockerfile; prebuilt release binaries are the alternative.
- Tagged version is injected via ldflags (`internal/version.GitTag`).
