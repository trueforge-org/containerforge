# nicholaswilde/docker-twtxt Dockerfile (pinned commit 3618126)

Source URL(s): https://raw.githubusercontent.com/nicholaswilde/docker-twtxt/3618126/Dockerfile (fetched 2026-11-27). root/ (s6 run scripts) not fetched: raw path guess returned 404.

## Build (stage `dl`)
- `FROM golang:1.16.5-alpine3.14 as dl`.
- ARG VERSION, CHECKSUM, FILENAME (default `${VERSION}.tar.gz`).
- apk: wget=1.21.1-r1, build-base=0.5-r2, git=2.32.0-r0, make=4.3-r0, ffmpeg-dev=4.4-r1.
- Downloads `https://github.com/prologic/twtxt/archive/refs/tags/${FILENAME}`, verifies `sha256sum -c` against `${CHECKSUM}`, extracts to /app (strip 1).
- Build: `make deps`, `go mod download`, `make server VERSION=${VERSION} COMMIT=HEAD` -> binary `twtd`.

## Runtime stage
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.14` (old base; s6-overlay style via `root/`).
- ARG BUILD_DATE, VERSION; LABEL build_version.
- ENV GODEBUG=netdns=cgo.
- apk: ffmpeg=4.4-r1, ca-certificates=20191127-r5.
- mkdir /data, /config/feeds; rm /tmp/*.
- COPY --from=dl /app/twtd /app/twtd; COPY root/ /.
- EXPOSE 8000.
- VOLUME /data /config.

## Entrypoint
- Not set in Dockerfile; run via s6 from root/ (not fetched).

## Ports / Volumes
- 8000/tcp; /data, /config (feeds under /config/feeds).

## Gotchas
- Pins are old (golang 1.16.5, alpine 3.14, ffmpeg 4.4). Binary is `twtd` (Go server from prologic/twtxt), not the Python CLI.
- Checksum-verified source tarball from GitHub tag archive.
