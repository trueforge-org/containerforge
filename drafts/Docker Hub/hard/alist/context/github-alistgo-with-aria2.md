# AlistGo/with_aria2 (wrapper image adding aria2)

**Source URL(s) + fetch date:** https://github.com/AlistGo/with_aria2/blob/12a215e1e1b1375f0512d4e2e310a35a4209e4de/Dockerfile (fetched as raw at that SHA) · fetched 2026-11-26

## What it is
Wrapper image that layers aria2 on top of `xhofe/alist:latest` via an install script. Named as the draft's Dockerfile source.

## Install/build steps and build deps
```
FROM xhofe/alist:latest
LABEL MAINTAINER="i@nn.ci"
VOLUME /opt/alist/data/
WORKDIR /opt/alist/
COPY entrypoint.sh /entrypoint.sh
COPY install.sh /install.sh
RUN chmod +x /entrypoint.sh /install.sh; /install.sh
ENV PUID=0 PGID=0 UMASK=022
EXPOSE 5244 6800
ENTRYPOINT [ "/entrypoint.sh" ]
```
- No ARG, no USER, no CMD.
- `install.sh` (not fetched) performs the aria2 install at build time.

## Runtime deps
Inherits from xhofe/alist (see `github-alistgo-alist.md`).

## Binaries/entrypoint/CLI flags
ENTRYPOINT `/entrypoint.sh` (this wrapper's own script, not fetched).

## Env vars
`PUID=0`, `PGID=0`, `UMASK=022`.

## Ports
`EXPOSE 5244 6800` (6800 = aria2 RPC).

## Volumes/paths
`VOLUME /opt/alist/data/`.

## Gotchas
- Exposes aria2 on 6800 with the wrapper's own entrypoint; the upstream alist entrypoint comments out `rpc-secret`, per the P3TERX config, so RPC is not secret-protected by default (per alist's Dockerfile, which does the same sed). Verify in `install.sh` (not fetched).
- Draft says the image bundles aria2 with an open RPC secret; consistent.
- Base image is `xhofe/alist:latest`, not pinned to a version.

## Contradictions with plan.md
- plan.md section 10 describes a wrapper where aria2 is an opt-in service with a required secret; this is a design choice of the port, not a contradiction of source facts.
