# Upstream image Dockerfile: nicholaswilde/docker-shorturl (commit 9362206)

Source URL: https://raw.githubusercontent.com/nicholaswilde/docker-shorturl/9362206/Dockerfile (fetched 2026-11-27)

## Build stage
- `FROM golang:1.14.15-alpine3.13 as build`.
- ARGs: VERSION, CHECKSUM, FILENAME="${VERSION}.tar.gz".
- WORKDIR `/go/src/github.com/prologic/shorturl`.
- apk pinned: wget=1.21.1-r1 git=2.30.2-r0 make=4.3-r0 build-base=0.5-r2.
- `wget -nv https://github.com/prologic/shorturl/archive/${FILENAME}` (GitHub mirror URL, not git.mills.io); `echo "${CHECKSUM}  ${FILENAME}" | sha256sum -c`.
- `tar -xvf ... --strip-components 1`; `make TAG=$VERSION BUILD=dev build`.

## Runtime stage
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.14`.
- `COPY --from=build --chown=abc:abc /go/src/github.com/prologic/shorturl/shorturl /app/shorturl`.
- `COPY root/ .` (s6 service scripts).
- `mkdir /data && chown -R abc:abc /data`.
- `EXPOSE 8000/tcp`.
- `VOLUME /app /data`.
- No ENV, USER, ENTRYPOINT, CMD in this file.
- LABEL build_version and maintainer.

## Gotchas
- Runtime is Alpine/musl and linuxserver s6 base (user `abc`).
- Build compiles prologic/shorturl with Go 1.14.
