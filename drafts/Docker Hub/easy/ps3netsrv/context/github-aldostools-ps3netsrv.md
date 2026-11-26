# aldostools/ps3netsrv (GitHub)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/aldostools/ps3netsrv (repo; README via https://raw.githubusercontent.com/aldostools/ps3netsrv/master/README.md)
- https://github.com/aldostools/ps3netsrv/releases (latest release page)
- Draft also cites the same project under https://github.com/aldostools/webMAN-MOD/tree/master/_Projects_/ps3netsrv: see github-aldostools-webman-mod-ps3netsrv.md

Not fetched: https://api.github.com/repos/aldostools/ps3netsrv/releases/tags/${VERSION} (contains ${, skipped), https://raw.githubusercontent.com/aldostools/ps3netsrv/${VERSION}/LICENSE.TXT (contains ${, skipped; plan records GPL-3.0-or-later from LICENSE.TXT).

## What it is
Network server that streams games from a PC/NAS to a PS3 (used with webMAN-MOD/multiMAN). Can decrypt encrypted PS3 ISOs on the fly and convert game folders to PS3 or standard ISOs. C/C++ project.

## Install/build steps and build deps
- Requirements: C/C++ compiler, Meson, mbed TLS (searched in system lib dirs and LIBRARY_PATH; for custom location set C_INCLUDE_PATH).
- Meson build:
  ```
  meson buildrelease --buildtype=release
  ninja -C buildrelease
  ```
- Alternate bundled-PolarSSL build (no Meson, no mbed TLS): Linux `./Make.sh` (static link); prerequisites `make`, `g++`. Windows `_make.bat`. If Linux reports "buffer overflow" errors, use this alternate method.
- Makefile.linux is used by the Dockerfile in shawly's wrapper: `make -f Makefile.linux BUILD_DATE=<date>` (BUILD_TYPE release_static; per plan.md, bundled PolarSSL AES, needs gcc/g++/make only).
- The Meson path is `meson build --buildtype=release -Dc_args=-DBUILD_DATE=... -Dcpp_args=-DBUILD_DATE=...` then `ninja -C build/` as used by shawly's Dockerfile.

## Runtime deps
- mbed TLS (Meson build) or none (bundled PolarSSL, static on Linux).
- Wrapper image adds libstdc++ and mbedtls3 runtime (see github-shawly-docker-ps3netsrv.md).

## Binaries/entrypoint/CLI flags
- `ps3netsrv [rootdirectory] [port] [whitelist]`
  - rootdirectory: if omitted, the ps3netsrv folder itself; can start with no args if GAMES, PS3ISO and PSXISO folders exist there.
  - port: default 38008.
  - whitelist: `x.x.x.x` where each x is 0-255 or `*` (e.g. `192.168.1.*`).
- Conversion/decryption mode: `ps3netsrv [game directory / encrypted iso] [PS3/ISO]`.
- Default game dirs: GAMES, PS3ISO, PSXISO.
- Binds INADDR_ANY (per plan.md, src/main.cpp line 99; not re-fetched).

## Env vars
None in upstream (env vars come from the shawly wrapper, see that file).

## Ports
- 38008 default (TCP).

## Volumes/paths and persistent data
- Root directory with game folders: GAMES (folder format), PS3ISO (ISO files), PSXISO. Multi-part ISOs `*.iso.0`, `*.iso.1`.
- Optional `folder_name.INI` merges multiple paths into one directory.

## Config files and formats
- No main config file. `folder_name.INI` as above. OpenWrt uses uci (see below).

## User/UID & permissions
- Not specified upstream.

## Healthcheck/readiness
- Not documented upstream (wrapper defines its own, see shawly file).

## Version/release info and asset naming
- Latest release: tag `20261110` (marked Latest, released 10 Nov, commit 9c5fe28). Release notes: fix for nested directory detection (PR #6 by Joonie86). Release page reports 6 assets; asset list did not render, so names come from plan.md / the release zip URL:
  - `ps3netsrv_20261110_linux.zip` (download URL pattern: `https://github.com/aldostools/ps3netsrv/releases/download/<TAG>/ps3netsrv_<TAG>_linux.zip`). Contains `ps3netsrv_20261110/ps3netsrv_ubuntu-latest_amd64.deb` plus distro deb/rpm and `makeiso`, per plan.md.
- Tag tarball: `https://github.com/aldostools/ps3netsrv/archive/refs/tags/<TAG>.tar.gz` (source).
- Tag format: date YYYYMMDD, sometimes with letter suffix (e.g. `20240210a`).
- Prebuilt binaries point to project Actions page `ps3netsrv-builds`.

## Arch support
- Upstream: prebuilt Linux amd64 only (per plan.md); other arches built from source. OpenWrt builds cover arm, arc, mips, mipsel, i386, powerpc, x86.
- Makefile.linux.arm exists in repo (ARM build script).

## Other upstream notes
- Up to 5 concurrent PS3 clients.
- Remote file ops (stat/open/create/read/close/delete/mkdir/rmdir) and directory listing (path ending with `//` lists subdirs).
- Source has a `NO_UPDATE` define (plan.md notes a possible update check; not verified).

## Gotchas
- Port 38008 must be reachable from the PS3; whitelist is per IP/range.
- OpenWrt: `uci set ps3netsrv.main.enabled='1'`, `.dir='/mnt/sda1'`, `.port='38008'`, `uci commit`.
