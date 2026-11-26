# epoupon/fileshelter

Source URL(s) + fetch date:
- https://github.com/epoupon/fileshelter (repo; README at tag v6.4.0, fetched 2026-11-26)
- https://raw.githubusercontent.com/epoupon/fileshelter/bcdddfab893b2cba8aa455261b36c88160e843e7/Dockerfile-release (fetched 2026-11-26)
- https://raw.githubusercontent.com/epoupon/fileshelter/v6.4.0/conf/fileshelter.conf (fetched 2026-11-26)
- https://raw.githubusercontent.com/epoupon/fileshelter/v6.4.0/COPYING (fetched 2026-11-26)
- https://raw.githubusercontent.com/epoupon/fileshelter/v6.4.0/README.md (fetched 2026-11-26)
- Source tarball (not downloaded, binary archive): https://github.com/epoupon/fileshelter/archive/refs/tags/v${VERSION}.tar.gz
- Dockerfile blob URL (plan): https://github.com/epoupon/fileshelter/blob/bcdddfab893b2cba8aa455261b36c88160e843e7/Dockerfile-release

## What it is

Self-hosted file sharing web app (C++, Wt web toolkit). Upload files, get a link. Shares have validity, optional password, multi-file zip on the fly, edit links, multi-language UI. CLI `fileshelter-cmd` to list/create/destroy shares.

## Install/build steps and build deps (upstream Dockerfile-release, alpine:3.23 two-stage)

Build stage `alpine:3.23 AS build`, `WORKDIR /tmp/workdir`, `ARG PREFIX="/tmp/install"`.

Build packages: `boost-dev bzip2 ca-certificates cmake coreutils curl g++ libarchive-dev libconfig-dev make openssl-dev pkgconfig tar zlib-dev`.

Wt build (`ARG WT_VERSION=4.12.3`):
- Download `https://github.com/emweb/wt/archive/${WT_VERSION}.tar.gz`, extract with `--strip-components=1`.
- `cmake -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE -DCMAKE_CXX_STANDARD=20 -DSHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DWT_CPP20_DATE_TZ_IMPLEMENTATIO="std" -DWT_CPP17_FILESYSTEM_IMPLEMENTATION="std" -DWT_CPP17_ANY_IMPLEMENTATION="std" -DBUILD_EXAMPLES=OFF -DENABLE_LIBWTTEST=OFF -DCONNECTOR_FCGI=OFF -DDEBUG=${WT_DEBUG}`; `make -j$(nproc) && make install`.
- Note: the option is spelled `WT_CPP20_DATE_TZ_IMPLEMENTATIO` (missing final N) upstream, and `${WT_DEBUG}` is never declared as an ARG. Copy with care.

Fileshelter build (`COPY . /tmp/fileshelter/`):
- `PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig CXXFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib -Wl,--rpath-link=${PREFIX}/lib" cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_UNITY_BUILD=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_PREFIX_PATH=${PREFIX}`.
- `LD_LIBRARY_PATH=${PREFIX}/lib VERBOSE=1 make -j$(nproc) install`, then `make test`, then `cp conf/fileshelter.conf ${PREFIX}/etc`.

Fakeroot step: strips `${PREFIX}/bin/fileshelter*` and `${PREFIX}/lib/*.so`; copies `lib`, `share` to `/tmp/fakeroot/`; removes `share/doc`, `share/man`, `share/Wt/resources/jPlayer`, `share/Wt/resources/themes/default`, `themes/polished`, `themes/bootstrap/2`, `themes/bootstrap/3`.

## Runtime deps

`libssl3 libcrypto3 zlib boost-program_options boost-thread libarchive libconfig++` (Alpine package names; Ubuntu equivalents must be looked up).

## Binaries/entrypoint/CLI flags

- Binary: `/usr/bin/fileshelter` (ENTRYPOINT, no args in Dockerfile). Installed by the build into `${PREFIX}/bin`, copied to `/usr/bin` in the release stage.
- CLI tool: `fileshelter-cmd` (list, create, destroy shares) (from README).
- Config path: conf copied to `/etc/fileshelter.conf` in the release stage; binary reads it by default (plan says argv[1] override; not verified here).

## Env vars

None. The Dockerfile sets no ENV; README and Hub page mention none. Settings live in the config file.

## Ports

- `EXPOSE 5091`. Config `listen = "0.0.0.0:5091"`.

## Volumes/paths and persistent data

- `VOLUME /var/fileshelter` (Dockerfile). `mkdir -p /var/fileshelter && chown -R fileshelter:fileshelter /var/fileshelter`.
- Config `working-dir = "/var/fileshelter";` ("Working directory (must have write privileges)").
- TLS files, if enabled: `/var/fileshelter/cert.pem`, `privkey.pem`, `dh2048.pem`.
- Web resources: `docroot = "/usr/share/fileshelter/docroot/;/resources,/css,/images,/js,/favicon.ico"`, `approot = "/usr/share/fileshelter/approot"`, `wt-resources = "/usr/share/Wt/resources"`.

## User/UID & permissions

- Runtime user: `fileshelter` group `fileshelter` created with `addgroup -S` / `adduser -S -H` (system user, no home). `USER fileshelter:fileshelter` in Dockerfile.
- Hub docs run with `--user <user_id:group_id>`.

## Config files and formats

`/etc/fileshelter.conf` (libconfig syntax). Full sample content (key values):
- `working-dir = "/var/fileshelter"`
- `log-file = ""`, `access-log-file = ""` (empty = stderr), `log-config = "* -debug -info:WebRequest"`
- `default-validity-days = 7`, `user-defined-validy-days = true` (sic), `max-validity-days = 100`
- `max-share-size = 100` (MB)
- `upload-passwords = ( );` (list)
- `listen = "0.0.0.0:5091"`, `behind-reverse-proxy = false`, `original-ip-header = "X-Forwarded-For"`, `trusted-proxies = ("127.0.0.1", "::1")`
- `tls-enable = false`, `tls-cert`, `tls-key`, `tls-dh` under `/var/fileshelter`
- `app-name = "FileShelter"`, `tos-org`, `tos-url`, `tos-support-email` placeholders; `tos-custom` commented
- `show-create-links-on-download = true`, `deploy-path = "/"`
- `docroot`, `approot`, `wt-resources` as above
- `bcrypt-count = 12`, `http-server-thread-count = 0` (auto)

## Healthcheck/readiness endpoints

None documented; no HEALTHCHECK in Dockerfile.

## Version/release info and asset naming

- Source tag `v6.4.0` (`v${VERSION}` in tarball URL). Plan says GitHub "Latest"; release assets not fetched.
- Wt pinned `4.12.3` in the upstream Dockerfile (`WT_VERSION`).
- Hub tags: `6.4.0@sha256:6524840f...` in chart; Hub page shows `latest`.

## Arch support

Not stated in upstream Dockerfile (alpine multi-arch base). Hub page lists no architectures.

## License

- `COPYING` at v6.4.0: GNU GPL version 3 text (29 June 2007). Plan `GPL-3.0-only` vs `or-later` is not settled by this file alone (it is the license text, not a per-file notice). README did not state the license.
- Bundled Wt is dual licensed: GPL v2 only with OpenSSL exception, or commercial (see github-emweb-wt.md).

## Gotchas

- Upstream `Dockerfile-release` builds on alpine (musl). glibc/Ubuntu port changes the runtime package names and may need different Boost headers.
- `user-defined-validy-days` key spelling is as shipped (typo in upstream).
- Upstream Dockerfile sets `working-dir` to `/var/fileshelter`; the seeded config must change it for a read-only rootfs.
- Build uses `make test` (fails the build on test failure upstream).
- Hub docs say config file bind mount to `/etc/fileshelter.conf` replaces defaults.

## Contradictions with plan.md

- None on port (5091 correct; draft 8080 wrong) or data path (`/var/fileshelter`).
- plan.md section 4 step 3 Wt flags omit `-DWT_CPP20_DATE_TZ_IMPLEMENTATIO`, `-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE`, and `-DDEBUG`. Upstream includes them. Plan uses its own set; note for the implementer.
