# GitHub: udo-munk/z80pack (upstream emulator)

## Source URL(s) + date
- https://raw.githubusercontent.com/udo-munk/z80pack/master/README.md (2026-11-27)
- https://github.com/udo-munk/z80pack/releases/latest (HTML, 2026-11-27; API fallback)
- Not fetched: https://api.github.com/repos/udo-munk/z80pack (repo) and /releases: skipped after /releases/latest returned HTTP 403 rate limit. One alternative (HTML) used.
- Not fetched: https://github.com/udo-munk/z80pack repo root (README + release cover it).

## What it is
- z80pack: Zilog Z80 / Intel 8080 emulator and cross-assembler for UNIX and Windows. Includes z80sim, z80asm, cpmsim (CP/M 1/2/3, MP/M 2), altairsim.

## Version
- Latest release: `z80pack release 1.38` (GitHub release page title).
- Branches: `master` = finished releases; `dev` = latest, under development.

## Build (from README)
- Ubuntu deps, X11: `build-essential libglu1-mesa-dev libjpeg9-dev`.
- Ubuntu deps, SDL2: `build-essential libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev`.
- Build: `make` (X11) or `WANT_SDL=YES make` (SDL2). Builds all MACHINES in Makefile.

## Run
- CP/M 2.2: `(cd cpmsim; ./cpm22)`. CP/M 3: `(cd cpmsim; ./cpm3)`.

## Asset / tag naming
- Tags are bare version numbers (e.g. `1.37`, `1.38`); source tarball `archive/refs/tags/<ver>.tar.gz` (used by plan, not fetched).

## Gotchas
- Release 1.38 is latest; the upstream image uses 1.37 (dlandon Dockerfile).
- README does not state a license. Plan's MIT claim could not be checked (API 403).
