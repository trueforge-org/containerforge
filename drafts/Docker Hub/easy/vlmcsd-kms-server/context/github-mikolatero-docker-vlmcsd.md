# mikolatero/docker-vlmcsd

Source URL(s) + fetch date: https://github.com/mikolatero/docker-vlmcsd (blob/master/Dockerfile via raw.githubusercontent.com) · fetched 2026-11-26

## What it is
- Thin Alpine wrapper that builds vlmcsd and runs it as the chart image `mikolatero/vlmcsd`.

## Build (Dockerfile)
- Stage 1 `alpine:latest AS builder`: `WORKDIR /root`; `apk add --no-cache git make build-base`; `git clone --branch master --single-branch https://github.com/Wind4/vlmcsd.git`; `cd vlmcsd && make`. Note: builds master, not the svn1113 tag.
- Stage 2 `alpine:latest`: copies `/root/vlmcsd/bin/vlmcsd` to `/vlmcsd` and `/root/vlmcsd/etc/vlmcsd.kmd` to `/vlmcsd.kmd`; `apk add --no-cache tzdata`.

## Runtime
- `EXPOSE 1688/tcp`
- `CMD ["/vlmcsd", "-D", "-d", "-t", "3", "-e", "-v"]`
- No USER, ENTRYPOINT, ENV or VOLUME instructions (runs as root).

## Gotchas
- The wrapper clones upstream `master` at build time, not a pinned tag. ContainerForge plan uses the `svn1113` tag instead.
- `-d` makes each client disconnect after one request, which the upstream man page says violates DCE RPC. Plan.md does not use `-d`.
