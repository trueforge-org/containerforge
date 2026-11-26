# alpinelinux/docker-alpine Dockerfile (v3.24, x86_64)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/alpinelinux/docker-alpine/v3.24/x86_64/Dockerfile (from the draft's blob link) · 2026-11-26

## Facts
- `FROM scratch`, `ADD alpine-minirootfs-3.24.4-x86_64.tar.gz /` (tarball name pattern `alpine-minirootfs-<version>-<arch>.tar.gz`, downloaded from dl-cdn.alpinelinux.org), `CMD ["/bin/sh"]`.
- No ARG, ENV or RUN.

## Notes
- The draft's Alpine image is the chart's `alpineImage` (init container only). Its base is a minirootfs tarball.
- Minirootfs URLs in draft/plan (`https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/{aarch64,x86_64}/alpine-minirootfs-3.24.4-<arch>.tar.gz`) are direct archive downloads, skipped.
