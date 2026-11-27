# shiori upstream Dockerfile (v1.8.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/go-shiori/shiori/v1.8.0/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Build stages
- `FROM docker.io/library/alpine:${ALPINE_VERSION} AS builder` (ALPINE_VERSION default `3.19`)
- `FROM scratch` (final)

## ARG / ENV
- ARG `ALPINE_VERSION=3.19`; ARG `TARGETARCH`, `TARGETOS`, `TARGETVARIANT` (no defaults)
- ENV `PORT=8080`; ENV `SHIORI_DIR=/shiori`

## Build steps
- builder: `apk add --no-cache ca-certificates tzdata`; `chmod +x /usr/bin/shiori`; `rm -rf /tmp/*`
- COPY binary `dist/shiori_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}/shiori` → `/usr/bin/shiori`
- final COPYs from builder: `/tmp`, `/usr/bin/shiori`, `/usr/share/zoneinfo`, `/etc/ssl/certs/ca-certificates.crt`

## Runtime
- WORKDIR `${SHIORI_DIR}` (= `/shiori`)
- EXPOSE `${PORT}` (8080)
- ENTRYPOINT `["/usr/bin/shiori"]`; CMD `["server"]`
- No USER, VOLUME, HEALTHCHECK, user/group creation.
- LABEL org.opencontainers.image.source = https://github.com/go-shiori/shiori

## Gotchas
- Scratch final image: no shell, no user.
