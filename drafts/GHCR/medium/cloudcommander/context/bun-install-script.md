# bun install script (https://bun.com/install)
Source URL(s): https://bun.com/install (fetched 2026-11-27)

## What it is
- Bash installer for the Bun runtime. Downloads a release zip from GitHub and installs the binary.

## Install behaviour
- Requires `unzip` (errors out if missing).
- Default: `$GITHUB/oven-sh/bun/releases/latest/download/bun-<target>.zip`; with arg 1: `releases/download/<tag>/bun-<target>.zip`.
- Target: linux-x64 (default), linux-aarch64 for aarch64/arm64; `-musl` suffix if /etc/alpine-release exists; `-baseline` suffix if no avx2 in /proc/cpuinfo.
- Install dir: $BUN_INSTALL, default $HOME/.bun; binary at $HOME/.bun/bin/bun.
- Riscv64 unsupported.
- Optional arg 2 `debug-info` uses bun-profile binary.

## Gotchas
- Relevant to cloudcmd Dockerfile: installs to /root/.bun (root HOME) at build time; the Dockerfile symlinks it to /usr/local/bin/bun.
