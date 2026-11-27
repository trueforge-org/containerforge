# restic/restic latest release (API)

## Source URL(s) + date
- https://api.github.com/repos/restic/restic/releases/latest (fetched 2026-11-27; used in place of github.com/restic/restic/releases HTML)

## What it is
- Latest release at fetch time: tag `v0.20.0`.

## Version/asset naming
- Linux assets: `restic_0.20.0_linux_<arch>.bz2` (arch: 386, amd64, arm, arm64, mips, mips64, mips64le, mipsle, ppc64le, riscv64, s390x, and more in the list). Compressed bz2, not tar.gz.
- Checksum asset name not extracted in this pass.

## Gotchas
- Assets are bz2-compressed single binaries; decompress before placing at a path.
- Backrest's own restic version is not confirmed (backrest downloads restic itself); this is only the upstream latest.
