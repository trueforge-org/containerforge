# Gridcoin-Research README (install/build facts)

Source URL: https://raw.githubusercontent.com/gridcoin-community/Gridcoin-Research/master/README.md
Date fetched: 2026-11-26

## Build
- `./build_targets.sh TARGET=native` (dynamic, system libs). Other targets: `depends` (static, portable), `win64` (cross from Linux), `macos`.
- Script installs deps on many Linux distros and macOS. `./build_targets.sh --help` lists options (Qt5/Qt6, ccache, build type).
- Manual docs: `doc/build.md`.
- Build system: CMake (inferred from workflow names).
- Qt5 or Qt6 selectable.

## Not stated in README
- Specific package names, binary names (`gridcoinresearchd`/`gridcoinresearch`) and flags
- Default P2P and RPC ports
- Data directory per OS, config file name

## Branches
- development (testnet only), testnet, staging, master (release tags), hotfix.

## License
- MIT (`COPYING`).

## Other
- Project site: https://gridcoin.us/
- Support: Discord, Matrix #gridcoin:matrix.org, Libera Chat #gridcoin-help
