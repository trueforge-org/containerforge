# GitHub garethgeorge/backrest (repo, latest release, Dockerfile)

## Source URL(s) + date
- https://api.github.com/repos/garethgeorge/backrest (fetched 2026-11-27)
- https://api.github.com/repos/garethgeorge/backrest/releases/latest (fetched 2026-11-27)
- https://raw.githubusercontent.com/garethgeorge/backrest/875c9cb51e626a75276a64da42c6a9ec0695010a/Dockerfile.alpine (pinned commit, fetched 2026-11-27)

## What it is
- Repo: TypeScript, 7992 stars at fetch time. License SPDX: GPL-3.0.
- Latest release: tag `v1.14.1`, published 2026-07-12T04:39:10Z.

## Release assets (v1.14.1)
- Linux: `backrest_Linux_x86_64.tar.gz`, `backrest_Linux_arm64.tar.gz`, `backrest_Linux_armv6.tar.gz`, `backrest_Linux_armv7.tar.gz`, `backrest_Linux_i386.tar.gz`
- Checksums: `backrest_1.14.1_checksums.txt` (note: version without `v` in checksum name, tag has `v`)
- Other: Darwin, Freebsd, Windows (zip), `BackrestSetup-x86_64.exe`

## Dockerfile.alpine (pinned commit 875c9cb)
- `FROM alpine:latest` (musl, single stage)
- `LABEL org.opencontainers.image.source=https://github.com/garethgeorge/backrest`
- apk add: tini ca-certificates curl bash rclone openssh tzdata docker-cli; `rclone selfupdate --stable`
- `RUN mkdir -p /tmp`
- `ARG TARGETPLATFORM`; `COPY $TARGETPLATFORM/backrest /backrest`; `COPY $TARGETPLATFORM/docker-entrypoint /docker-entrypoint` (goreleaser dockers_v2 staging)
- `RUN /backrest --install-deps-only` (installs restic into `/root/.local/share/backrest/restic`)
- `RUN mkdir -p /bin && mv /root/.local/share/backrest/restic /bin/restic`
- `ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint"]`; `CMD ["/backrest"]`

## Install/build steps + deps
- Upstream image is built by goreleaser; not reproducible from source alone without the staged binary.
- Restic is downloaded at build time by backrest itself (`--install-deps-only`); no pinned restic version in the Dockerfile.

## Runtime deps
- tini, rclone, openssh, docker-cli, tzdata, ca-certificates (from Dockerfile.alpine). restic (installed by backrest).

## Version/asset naming
- Tag `v1.14.1`; asset/checksum names use `1.14.1` (no `v`) and `Linux_x86_64` / `Linux_arm64` arch names.

## Gotchas
- Upstream image is musl/Alpine; not copy-compatible with a glibc Ubuntu base.
- Restic version is not pinned upstream; the latest restic release at fetch time is v0.20.0 (see restic-restic.md), but backrest's own bundled restic version is not confirmed.
