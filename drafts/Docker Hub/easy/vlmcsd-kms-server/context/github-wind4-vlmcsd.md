# Wind4/vlmcsd

Source URL(s) + fetch date: https://github.com/Wind4/vlmcsd · https://raw.githubusercontent.com/Wind4/vlmcsd/svn1113/man/vlmcsd.8 · https://github.com/Wind4/vlmcsd/releases/tag/svn1113 · raw README at master and at svn1113 returned 404 (see README.md failures) · raw LICENSE at svn1113 returned 404 · fetched 2026-11-26

## What it is
- "Portable open-source KMS Emulator in C" (per Docker Hub description). Serves Microsoft KMS activation requests for volume-licensed Windows/Office clients.
- Repository is archived by its owner (archived 14 Aug 2024, read-only).

## Install/build steps and build deps
- Source build with GNU make from the source root (`make`). Dockerfile of mikolatero/docker-vlmcsd builds it on Alpine with `apk add --no-cache git make build-base`, then `make`, outputs `bin/vlmcsd`.
- Source tarball pattern: `https://github.com/Wind4/vlmcsd/archive/refs/tags/svn1113.tar.gz` (not downloaded here; extracts to `vlmcsd-svn1113/` per plan.md).
- Config template: `etc/vlmcsd.kmd` (KMD file) is copied next to the binary by the upstream wrapper.

## Runtime deps
- None beyond libc. Outputs: `vlmcsd` (server) and `vlmcs` (test client). Build needs gcc/make (`build-base` on Alpine).

## Binaries/entrypoint/CLI flags (man vlmcsd.8, svn1113)
| Option | Description | Default |
| --- | --- | --- |
| `-D` | Stay in foreground (not daemonize) | daemonizes |
| `-e` | Log to stdout (overrides `-l`) | off |
| `-l <file>` | Log activations to a file; `syslog` = syslog | no log |
| `-p <file>` | pid file | none |
| `-L <ip>[:port]` | Listen address (repeatable; IPv6 with port needs brackets) | 0.0.0.0 and :: on port 1688 |
| `-P <port>` | Default port for later `-L` entries (must precede `-L`) | 1688 |
| `-t <sec>` | TCP timeout | 30 |
| `-v` / `-q` | Verbose / non-verbose logging (only matters when logging is active) | off |
| `-d` / `-k` | Disconnect each client after one request (violates DCE RPC) / restore default | off |
| `-i <file>` | ini config file; command line wins; `-i-` ignores compiled-in default | possibly compiled-in path |
| `-m <n>` | Max concurrent clients | no limit |
| `-u <user>` / `-g <group>` | Drop privileges after socket creation | no switch |
| `-r0/-r1/-r2` | ePID mode (0 fixed, 1 random at start/SIGHUP, 2 per request) | `-r1` |
| `-K0..-K3` | Whitelisting level | `-K0` |
| `-c0/-c1` | `-c1` checks client time within 4 h of system time | `-c0` |
| `-o0..-o3` | Restrict public/private IP handling | `-o0` |
| `-R` / `-A` | Renewal interval (default 10080 min) / retry interval (default 120 min) | |
| `-V`, `-h` | Version info / help | |

## Env vars
- None documented. The man page does not mention environment variables or TZ.

## Ports
- `1688/tcp` (KMS default). Default listen addresses 0.0.0.0 and :: unless `-L` is used.

## Volumes/paths and persistent data
- None required. Upstream wrapper copies `etc/vlmcsd.kmd` to `/vlmcsd.kmd`.

## User/UID & permissions
- Upstream mikolatero Dockerfile sets no USER (root). `-u`/`-g` can drop privileges.

## Healthcheck/readiness endpoints
- None documented. Port check only.

## Version/release info and asset naming
- Latest tag/release: `svn1113` (release notes dated 2020-03-28, build 1113). Tags svn1111, svn1112, svn1113 per plan.md. Renovate pattern is `github-tags` (plan.md).
- Release assets: "Assets 3" on the release page; names did not load. Known name from draft/plan: `binaries.tar.gz` (~22 MB, Linux builds for x64-glibc, x64-musl-static, x86, arm 32-bit, mips, ppc, s390, sparc; no linux aarch64 per plan.md).
- Release notes: .kmd format 2.0 (1.x files no longer work); -v logs every CSVLK at startup; NDR64 selection; no LICENSE mentioned.

## Arch support
- Source build works on any arch with a C toolchain (plan.md builds arm64 from source). Prebuilt tarball has no linux aarch64 binary (per plan.md).

## Config files and formats
- `vlmcsd.kmd` (KMD file, format 2.0 since svn1113). `vlmcsd.ini` (ini). Both optional.

## License
- No LICENSE file at svn1113 (404). The release notes mention no license. Plan.md's NOASSERTION choice stands.

## Gotchas
- Archived repo: no newer releases expected; Renovate github-tags may find nothing new.
- README is not available from the two raw URLs tried (404 at master and at svn1113).
- Release page notes a GPG signature mention, unrelated to package integrity.
