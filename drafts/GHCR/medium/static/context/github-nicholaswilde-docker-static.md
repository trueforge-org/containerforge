# GitHub: nicholaswilde/docker-static (commit f52fab6)

Source URL(s): https://raw.githubusercontent.com/nicholaswilde/docker-static/f52fab6/Dockerfile (fetched 2026-11-27)

## What it is
- Image wrapping prologic/static (Go static file server). Two-stage build.

## Dockerfile
- Stage build: `golang:1.16.5-alpine3.14`; ARG VERSION, COMMIT; ENV GO111MODULE=on; WORKDIR /go/src/static.
  - apk add `git=2.32.0-r0 make=4.3-r0 build-base=0.5-r2` (pinned)
  - `git clone https://github.com/prologic/static.git /go/src/static`; `git reset --hard ${COMMIT}`; `go get -v -d`; `go install -v`.
- Stage runtime: `ghcr.io/linuxserver/baseimage-alpine:3.14`; ARG BUILD_DATE, VERSION; ENV GOPATH=/go.
  - LABEL build_version, maintainer nicholaswilde.
  - COPY --from=build --chown=abc:abc /go /go; COPY root/ /  (s6 overlay files, not fetched).
  - RUN mkdir /data; chown -R abc:abc /data /go.
- WORKDIR /data; EXPOSE 8000/tcp; VOLUME /data.

## Users
- Runtime user `abc` (linuxserver base convention, as used in chown). UID not stated in Dockerfile.

## Ports
- 8000/tcp

## Volumes/paths
- /data (VOLUME, workdir). Go install output under /go.

## Gotchas
- Pinned to Alpine 3.14 and Go 1.16.5 (old); upstream clone is prologic/static.
- Entrypoint/run script lives in `root/` overlay, not fetched.
