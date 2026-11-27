# Notifiarr upstream Dockerfile.alpine + release

Source URL(s) + date: https://raw.githubusercontent.com/Notifiarr/notifiarr/85a85e8/init/docker/Dockerfile.alpine ; https://github.com/Notifiarr/notifiarr/releases/latest (HTML alternative, fetched 2026-11-27)
Pinned commit in urls.txt: 85a85e8 (release v0.10.0 points at same commit).

## Dockerfile (single stage)
| Item | Value |
| --- | --- |
| Base | alpine:3.24 (pinned by digest) |
| ARG | TARGETPLATFORM (no default) |
| COPY | `--chmod=755 ${TARGETPLATFORM}/notifiarr /notifiarr` |
| RUN | `apk add --no-cache ca-certificates ipmitool smartmontools zfs sysstat tzdata && rm -f /bin/iostat` |
| ENV | TZ=UTC; PATH=/bin:/usr/bin:/sbin:/usr/sbin; USER=root (ENV only, no USER instruction) |
| EXPOSE | 5454 |
| ENTRYPOINT | ["/notifiarr"] |
| CMD / VOLUME / HEALTHCHECK / WORKDIR / USER | not set |

- Binary is pre-built per TARGETPLATFORM directory (not compiled in this Dockerfile).
- rm /bin/iostat: sysstat iostat noted as wrong version for snapshots.

## Runtime
- Runs as root (no USER instruction, UID/GID unspecified).
- Hardware tools present: ipmitool, smartmontools, zfs, sysstat.

## Release (GitHub, HTML alternative)
- Latest: v0.10.0 (marked Latest), published "07 Nov" (year not shown), commit 85a85e8 (signed).
- Compare range v0.9.7...v0.10.0.
- Asset count shown: 33; individual asset names not retrieved (list did not load). API releases/latest returned 403 (not retried).

## Gotchas
- Image pins alpine:3.24 by digest; keep aligned if rebuilding.
- Chart sets no securityContext; image runs as root.
