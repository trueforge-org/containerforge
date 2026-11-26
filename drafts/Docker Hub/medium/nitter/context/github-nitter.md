# GitHub: zedeus/nitter (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/zedeus/nitter/master/Dockerfile (2026-11-26)
- https://raw.githubusercontent.com/zedeus/nitter/145ca9eb68d195a74598ae39a4d6da002b252c38/Dockerfile (2026-11-26; byte-identical to master)
- https://github.com/zedeus/nitter/releases (HTML, 200, no tag links)
- https://api.github.com/repos/zedeus/nitter/releases/latest: 403 (rate limit), failed

## What it is
Nim web front-end (Twitter alternative). No tags/releases found.

## Dockerfile (master = pinned commit 145ca9eb)
- Build stage: `FROM nimlang/nim:2.2.6-alpine-regular AS nim`. `apk add libsass-dev pcre`. `WORKDIR /src/nitter`. `COPY nitter.nimble .`, `nimble install -y --depsOnly`, `COPY . .`, `nimble build -d:danger -d:lto -d:strip --mm:refc && nimble scss && nimble md`.
- Final stage: `FROM alpine:latest`, `WORKDIR /src/`, `apk add pcre ca-certificates openssl`.
- Copies: `/src/nitter/nitter` -> `./`, `/src/nitter/nitter.example.conf` -> `./nitter.conf`, `/src/nitter/public` -> `./public`.
- `EXPOSE 8080`, `adduser -h /src/ -D -s /bin/sh nitter`, `USER nitter`, `CMD ./nitter`.
- No ENTRYPOINT, no VOLUME, no HEALTHCHECK, no ENV.

## Install/build deps
- Nim 2.2.6 (alpine image only), libsass-dev, pcre (build); pcre, ca-certificates, openssl (runtime).
- Maintainer label: setenforce@protonmail.com (not used in build).

## Runtime deps
- pcre, ca-certificates, openssl. Redis/Valkey used by chart (not verified in source files fetched).

## Entrypoint/flags
- CMD `./nitter` (from /src). No flags.

## Ports
- 8080/tcp (EXPOSE). Chart uses 10606 (see truecharts-nitter.md).

## Volumes/paths
- Work dir `/src/`: binary `nitter`, `nitter.conf`, `public/`.

## User/UID
- `nitter` user created with adduser -D (UID not pinned in Dockerfile); `USER nitter`.

## Config files
- `nitter.conf` copied from `nitter.example.conf` at build time. Chart mounts a secret at `/src/nitter.conf`.

## Healthcheck
- None.

## Version/asset naming
- No tags or releases (releases page has no tag links; API latest call 403). Source archive by commit SHA.

## Arch
- Upstream Dockerfile uses multi-arch-capable images; Docker Hub tags list amd64 and arm64.

## Gotchas
- Default branch is `master`: raw `main/Dockerfile` returned 404, `master/Dockerfile` returned 200. Plan link was `blob/main` (corrected in plan.md).
- Pinned commit Dockerfile is identical to master at fetch time.
