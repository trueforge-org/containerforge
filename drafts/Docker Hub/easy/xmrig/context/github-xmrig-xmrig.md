# xmrig/xmrig

Source URL(s) + fetch date: https://github.com/xmrig/xmrig · https://raw.githubusercontent.com/xmrig/xmrig/master/README.md · https://raw.githubusercontent.com/xmrig/xmrig/v6.27.0/src/version.h · https://raw.githubusercontent.com/xmrig/xmrig/v6.27.0/src/config.json · https://github.com/xmrig/xmrig/releases · fetched 2026-11-26

## What it is
- "High performance, open source, cross platform" CPU/GPU miner. Algorithms include RandomX, KawPow, CryptoNight, GhostRider. Also a RandomX benchmark.
- Backends: CPU (x86/x64/ARMv7/ARMv8/RISC-V), OpenCL (AMD), CUDA (NVIDIA, separate plugin repository).
- Official prebuilt binaries for Windows, Linux, macOS, FreeBSD.
- Developers listed as xmrig and sech1.

## Install/build steps
- Prebuilt binaries on the GitHub releases page. Source build documented at xmrig.com/docs/miner/build (not fetched).
- No Dockerfile is mentioned upstream (releases page and README).

## Runtime deps
- Not stated in fetched content. plan.md lists libuv, hwloc, OpenSSL as Ubuntu package dependencies (not verified here).

## Binaries/entrypoint/CLI flags
- Binary `xmrig` (Debian/Ubuntu package path `/usr/bin/xmrig` per plan.md, not verified).
- Command-line options (xmrig.com/docs/miner/command-line-options, fetched): `-o/--url`, `-u/--user`, `-p/--pass`, `-O/--userpass`, `--rig-id`, `--tls`, `--tls-fingerprint`, `-k/--keepalive`, `--donate-level` (default 1%), `-t/--threads`, `--no-huge-pages`, `--http-host` (default 127.0.0.1), `--http-port`, `--http-access-token`, `--http-no-restricted`, `-c/--config`, `--no-color`, `--print-time`, `--user-agent`, `--cpu-max-threads-hint`, `--dry-run`, `-V/--version`, `-h/--help`, `--randomx-1gb-pages`, `--randomx-wrmsr`, `--randomx-no-rdmsr`, `--huge-pages-jit`, and others (see the fetched page).
- Donate level: README states the default is 1% (1 minute in 100).

## Env vars
- Upstream reads none (per plan.md, not contradicted). Wrapper env names are plan.md's `XMRIG_*` design.

## Config files and formats
- `config.json` (JSON), loaded with `--config` / `-c`. Sample at `src/config.json` (v6.27.0):
  - `autosave`: true
  - `donate-level`: 1
  - `http`: `enabled` false, `host` "127.0.0.1", `port` 0, `access-token` null, `restricted` true
  - `pools[0]`: `url` "donate.v2.xmrig.com:3333", `user` "YOUR_WALLET_ADDRESS", `pass` "x", `rig-id` null, `tls` false, `keepalive` false
  - `randomx`: `rdmsr` true, `wrmsr` true, `1gb-pages` false
  - `cpu.huge-pages`: true
- The JSON config is recommended over the command line (README).

## Ports
- HTTP API: off by default. Plan.md enables it on `0.0.0.0:8080` restricted mode via `--http-host`/`--http-port`.

## Volumes/paths and persistent data
- No paths required upstream. `autosave` can write the loaded config file back.

## User/UID & permissions
- MSR tweaks (`rdmsr`/`wrmsr`) and 1 GB huge pages need root/privileged. The `--randomx-no-rdmsr` option skips MSR revert on exit.

## Healthcheck/readiness endpoints
- None documented in fetched content. The HTTP API is documented at xmrig.com/docs/api (not fetched).

## Version/release info and asset naming
- `src/version.h` at v6.27.0: `APP_VER_MAJOR` 6, `APP_VER_MINOR` 27, `APP_VER_PATCH` 0, `APP_VERSION` "6.27.0".
- Latest release v6.27.0, dated 23 Nov (assets 2026-11-23).
- Assets (first 11 of 14 visible): `SHA256SUMS`, `SHA256SUMS.sig`, `xmrig-6.27.0-freebsd-static-x64.tar.gz`, `xmrig-6.27.0-jammy-x64.tar.gz`, `xmrig-6.27.0-linux-static-x64.tar.gz`, `xmrig-6.27.0-macos-arm64.tar.gz`, `xmrig-6.27.0-macos-x64.tar.gz`, `xmrig-6.27.0-noble-x64.tar.gz`, `xmrig-6.27.0-resolute-x64.tar.gz`, `xmrig-6.27.0-windows-arm64.zip`, source zip and tar.gz. Checksum list also names `xmrig-6.27.0-windows-gcc-x64.zip` and `xmrig-6.27.0-windows-x64.zip`.
- No `linux-arm64` or `linux-static-arm64` asset in the listing or the checksum list (confirms plan.md).

## Arch support
- Linux x64 assets only in the listed release files (static, jammy, noble, resolute). arm64 Linux is not in the release list; plan.md's apt route for arm64 is the only one planned.

## License
- The README shows a license badge but does not name the license (plan.md says GPL-3.0 from LICENSE). Not confirmed in fetched content.

## Gotchas
- `XMRIG_DONATE_LEVEL` default 1 in plan.md matches the upstream default (1%).
- Upstream sample `config.json` has a pool pointing at `donate.v2.xmrig.com:3333` and `user` "YOUR_WALLET_ADDRESS".
- Policy: the plan's own section 10 calls this a cryptominer requiring maintainer sign-off. These facts do not change that.
