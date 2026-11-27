# Upstream Dockerfile: Jonnyan404/verysync @ 29eb0b8 (master identical, fetched 2026-11-27)

Source URL(s) + date: https://raw.githubusercontent.com/Jonnyan404/verysync/29eb0b8c40c2e2f9e62b3f00368e152f15066a78/Dockerfile and https://raw.githubusercontent.com/Jonnyan404/verysync/master/Dockerfile (byte-identical; fetched 2026-11-27)

## Build (2 stages, alpine:latest both)
- Builder stage:
  - ENV TZ=Asia/Shanghai, PORT=8886, VUID=0; WORKDIR /app; ARG TARGETPLATFORM, ARG VERSION.
  - COPY docker-entrypoint.sh /app/.
  - COPY files/verysync-linux-{amd64,arm64,arm}-${VERSION}.tar.gz to /tmp (build context must contain `files/`; not in repo listing fetched).
  - apk add tzdata bash; mkdir /data; chmod 777 /data; addgroup/adduser `nonverysync`.
  - Per TARGETPLATFORM (linux/amd64, linux/arm64, linux/arm/v7): extract tarball, move `verysync` binary to /usr/bin/.
  - gosu 1.19 downloaded from github.com/tianon/gosu releases (gosu-amd64 / gosu-arm64 / gosu-armhf) to /usr/local/bin/gosu; `gosu nobody true` sanity check.
- Final stage (alpine:latest):
  - ENV same (TZ, PORT=8886, VUID=0); WORKDIR /app.
  - COPY --from=builder /usr/bin/verysync and /usr/local/bin/gosu; COPY docker-entrypoint.sh.
  - apk add tzdata bash; /data 777; user nonverysync; chmod binaries.
  - HEALTHCHECK --interval=1m --timeout=10s CMD `nc -z 127.0.0.1 ${PORT} || exit 1`.
  - ENTRYPOINT ["/app/docker-entrypoint.sh"]; no CMD, no EXPOSE, no USER (root entry).

## Build ARGs
| ARG | Use |
| --- | --- |
| TARGETPLATFORM | platform switch (amd64, arm64, arm/v7) |
| VERSION | selects files/verysync-linux-<arch>-${VERSION}.tar.gz |

## Arch
- linux/amd64, linux/arm64, linux/arm/v7 only. Other platforms: no verysync binary copied (build would fail at chmod/mv or later step; not verified).

## Gotchas
- Gosu is downloaded at build time from GitHub (network needed at build).
- Upstream image runs as root and drops to VUID via gosu in entrypoint.
