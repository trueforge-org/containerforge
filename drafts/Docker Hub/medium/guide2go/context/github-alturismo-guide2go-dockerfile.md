# alturismo/guide2go: Dockerfile (master)
Source URL(s): https://github.com/alturismo/guide2go/blob/master/Dockerfile = raw master Dockerfile (fetched 2026-11-26, 35 lines)

## Build
- Base: alpine:latest (unpinned)
- RUN apk update; apk upgrade; apk add ca-certificates curl tzdata bash busybox-suid su-exec
- ENV TZ=Europe/Berlin; symlinks /etc/localtime and /etc/timezone
- MAINTAINER alturismo (deprecated label form)
- ADD guide2go /usr/bin/guide2go (prebuilt Go binary expected in the build context, not built in this Dockerfile)
- ADD cronjob.sh /, ADD entrypoint.sh /, ADD sample_cron.txt /
- chmod +x /entrypoint.sh /cronjob.sh /usr/bin/guide2go
- VOLUME /config, VOLUME /guide2go
- ENTRYPOINT ["./entrypoint.sh"] (relative path, WORKDIR is /)
- No EXPOSE, no USER (runs as root), no HEALTHCHECK

## Gotchas
- Build context must contain a `guide2go` binary (built from mar-mei/guide2go, Go; see README) plus cronjob.sh, entrypoint.sh, sample_cron.txt.
- Image is not read-only-rootfs friendly: entrypoint writes /config/cronjob.sh, /config/cron.txt, /etc/crontabs/root.
