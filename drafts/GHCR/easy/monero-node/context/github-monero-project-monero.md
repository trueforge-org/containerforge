# monero-project/monero (upstream source, v0.18.5.4)

**Source URL(s):** https://github.com/monero-project/monero/releases/tag/v0.18.5.4 ; https://raw.githubusercontent.com/monero-project/monero/v0.18.5.4/LICENSE
**Fetched:** 2026-11-26 (the repo root page itself was not fetched; release page and LICENSE were)

## What it is
Monero: the reference C++ implementation of a private, decentralised cryptocurrency. `monerod` is the full-node daemon; `monero-wallet-cli` and others are also in the tarball.

## Release v0.18.5.4
- Title "Fluorine Fermi, Point Release 5.4". Marked Latest. Published 17 Oct (year not shown on page; plan.md says 2026-10-17).
- Minor release with bug fixes. Daemon: DNSSEC validation fixed for checkpoints, blocklists and update checks (#11542). RPC: string-to-integer conversion in JSON requests restored; slated for removal in v0.19 as a breaking change (#11552).
- Tag signed by tobtoht (GPG key E45B10DD027D2472), commit 85f036b (the upstream wrapper pins 85f036ba7019cd36f08e8a38a27c37ea7b522618).
- Release notes list SHA256 hashes per download, and point to the canonical GPG-signed list at https://getmonero.org/downloads/hashes.txt (see getmonero-downloads-hashes.md).
- Release notes say "2 assets" but the names did not load; the notes name downloads, including:
  - `monero-linux-x64-v0.18.5.4.tar.bz2` (amd64)
  - `monero-linux-armv8-v0.18.5.4.tar.bz2` (arm64)
  - Also armv7, x86, riscv64, mac, win, android, freebsd variants.

## Download URL pattern
`https://downloads.getmonero.org/cli/monero-<os>-<arch>-v<VERSION>.tar.bz2`. Relevant pair for this app: `linux-x64` (amd64) and `linux-armv8` (arm64). Plan.md's Content-Length: amd64 85037503, armv8 74776406 (from the plan's own check). These are binary downloads, not fetched here.

## Install/build steps and build deps
- Official tarball is used (no source build in the plan). The upstream image builds a static monerod from source (see github-sethforprivacy-simple-monerod-docker.md).
- Source build (for reference only): cmake, Boost, OpenSSL, libunbound, libsodium, etc. Not needed.

## Runtime deps
- glibc Linux binary from the tarball. The upstream wrapper's runtime packages: curl, ca-certificates, libsodium, ncurses-libs, numactl-tools, readline, su-exec, tzdata, zeromq (Alpine names). The plan's Ubuntu base should provide the glibc side; verify with `ldd` (plan.md step 2).

## Binaries / CLI flags
- `monerod` in the tarball's top-level folder (inner directory name unverified; plan.md step 2).
- Flags used by the upstream image CMD (see wrapper summary): `--rpc-restricted-bind-ip=0.0.0.0`, `--rpc-restricted-bind-port=18089`, `--no-igd`, `--no-zmq`, `--enable-dns-blocklist`, `--ban-list=/home/monero/ban_list.txt`.
- `--non-interactive` (used by the wrapper entrypoint) keeps monerod in the foreground logging to stdout.
- The chart also sets `publicnode: true` (see truecharts summary), which implies `--public-node`.

## Env vars
None read by monerod itself. The upstream wrapper entrypoint reads `PUID` and `PGID` only (see wrapper summary).

## Ports
- 18080/tcp: P2P (main).
- 18089/tcp: restricted RPC (upstream EXPOSE and CMD).
- 18081: unrestricted RPC, not used here (plan corrected the draft's `18081/http`).

## Volumes/paths
- Data dir default: `~/.bitmonero`. The upstream wrapper uses `/home/monero/.bitmonero`. The plan remaps to `/config/bitmonero` via `--data-dir`.
- Blockchain is large (plan.md says well over 100 GB, unverified). Chart mounts `blockchainstorage` at `/home/monero/.bitmonero`.

## User/UID and permissions
Upstream wrapper: root PID 1 drops to PUID/PGID via su-exec. We run as `apps` (plan). The upstream monero-ban-list is read from the data area.

## Config files
None required. Flags only. The `--ban-list` file is optional (plan section 2).

## Healthcheck / readiness
Upstream wrapper healthcheck: `GET http://127.0.0.1:<restricted-bind-port>/get_height` (default 18081 if no flag). See wrapper summary.

## Version/release info
- Latest: v0.18.5.4 (Oct 2026). Renovate (plan.md): `datasource=github-releases depName=monero-project/monero versioning=loose`.

## Arch support
- Official tarballs: linux-x64, linux-armv8 (and linux-armv7, linux-x86, linux-riscv64, plus mac, win, android, freebsd).
- The plan uses amd64 and arm64 only.

## License
- LICENSE at v0.18.5.4: BSD 3-Clause ("New" or "Revised"). Copyright (c) 2014-2022, The Monero Project (this tag). Plan.md read the master copy (2014-2024). The page also notes parts originally copyright Cryptonote (2012-2013) and Boolberry (2014, MIT).
- SPDX: `BSD-3-Clause` (the plan's value). Note the copyright years differ between the tag and master; SPDX is the same.

## Gotchas
- The release notes name "linux-armv8" for arm64; use the `linux-armv8` file (not `linux-arm64`).
- Hash list is GPG clearsigned; this session did not verify the PGP signature.
