# github.com/Cisco-Talos/clamav-docker (upstream Dockerfile, clamav/1.5/debian at commit 0d44a24)

Source URL(s) + fetch date:
- https://github.com/Cisco-Talos/clamav-docker/blob/0d44a2479470a57af03f1e212e764f1bee57fc8a/clamav/1.5/debian/Dockerfile (raw: https://raw.githubusercontent.com/Cisco-Talos/clamav-docker/0d44a2479470a57af03f1e212e764f1bee57fc8a/clamav/1.5/debian/Dockerfile) · fetched 2026-11-26

## What the Dockerfile does
- Builds ClamAV **from source** (not the vendor .deb) in a `builder` stage on `${BASE_IMAGE}` (default `debian:13-slim`), then copies `/clamav` into the final stage.
- Header SPDX: `GPL-2.0-or-later` (this is the clamav-docker project's header; it does not decide the ClamAV licence).

## Build deps (builder stage apt)
cmake, bison, flex, gcc, git, make, man-db, net-tools, pkg-config, python3, python3-pip, python3-pytest, check, libbz2-dev, libcurl4-openssl-dev, libjson-c-dev, libmilter-dev, libncurses-dev, libpcre2-dev, libssl-dev, libxml2-dev, zlib1g-dev, curl. Rust via rustup (sh.rustup.rs, unpinned, `rustup update`). Tests: `ctest -V --timeout 3000`.

## Build flags (cmake)
`CMAKE_BUILD_TYPE=Release`, `CMAKE_INSTALL_PREFIX=/usr`, `CMAKE_INSTALL_LIBDIR=/usr/lib`, `APP_CONFIG_DIRECTORY=/etc/clamav`, `DATABASE_DIRECTORY=/var/lib/clamav`, `ENABLE_CLAMONACC=OFF`, `ENABLE_EXAMPLES=OFF`, `ENABLE_JSON_SHARED=ON`, `ENABLE_MAN_PAGES=OFF`, `ENABLE_MILTER=ON`, `ENABLE_STATIC_LIB=OFF`. `make` with `DESTDIR=/clamav`.

## Generated configs (sed from .sample, in /clamav/etc/clamav/)
- clamd.conf: LocalSocket `/tmp/clamd.sock`, TCPSocket `3310`, TCPAddr `0.0.0.0` (commented), `User clamav`, `LogFile /var/log/clamav/clamd.log`, `LogTime yes`.
- freshclam.conf: `DatabaseOwner clamav`, `UpdateLogFile /var/log/clamav/freshclam.log`, `NotifyClamd /etc/clamav/clamd.conf`, `ScriptedUpdates yes`.
- clamav-milter.conf: `MilterSocket inet:7357`, `User clamav`, `LogFile /var/log/clamav/milter.log`, `ClamdSocket unix:/tmp/clamd.sock`.

## Final stage
- Runtime packages: libbz2-1.0, libcurl4, libssl3, libjson-c5, libmilter1.0.1, libncurses6, libpcre2-8-0, libxml2, zlib1g, tzdata, netcat-openbsd. `ENV TZ=Etc/UTC`.
- User `clamav` UID 1000 / group `clamav` GID 1000, shell `/bin/false`, home `/var/lib/clamav` (chowned). `/var/log/clamav` owned by clamav (755).
- Scripts: `scripts/clamdcheck.sh` -> `/usr/local/bin/`; `scripts/docker-entrypoint.sh` -> `/init`; `scripts/docker-entrypoint-unprivileged.sh` -> `/init-unprivileged`.
- `EXPOSE 3310 7357`. No `VOLUME`. `HEALTHCHECK` = clamdcheck.sh with 6-minute start period. `ENTRYPOINT ["/init"]`, no CMD.
- No `USER`: starts as root; the unprivileged entrypoint `/init-unprivileged` is the non-root route.

## Gotchas for this plan
- The upstream image has a healthcheck script (`clamdcheck.sh`) which could be reused for a container health probe. Not in plan.
- `/init-unprivileged` exists; the plan's own start.sh (dropping the `clamav` user, using `apps`) is a rework and not copied from it. The script body was not fetched.
