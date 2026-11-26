# Gridcoin-Research releases (latest)

Source URL: https://api.github.com/repos/gridcoin-community/Gridcoin-Research/releases/latest
Date fetched: 2026-11-26

## Latest
- tag_name: `5.5.3.0`, name `5.5.3.0-leisure`, published 2026-11-20

## Assets (Linux, relevant)
| Asset | Notes |
| --- | --- |
| gridcoinresearch-5.5.3.0-x86_64.tar.gz | 39.6 MB, Linux tarball |
| gridcoinresearch-qt_5.5.3.0.bookworm-1_{amd64,arm64,armhf,i386}.deb | Qt GUI, Debian bookworm |
| gridcoinresearch-qt_5.5.3.0.trixie-1_{amd64,arm64,armhf,i386}.deb | Qt GUI, Debian trixie |
| gridcoinresearchd_5.5.3.0.bookworm-1_{amd64,arm64,armhf,i386}.deb | daemon, Debian bookworm |
| gridcoinresearchd_5.5.3.0.trixie-1_{amd64,arm64,armhf,i386}.deb | daemon, Debian trixie |
| gridcoin-5.5.3.0-x86_64.flatpak | 18.4 MB, Flatpak (includes daemon) |

## Other assets
- macOS: `gridcoin-5.5.3.0-macos-arm64.dmg`, `...-macos-x86_64.dmg`, `...-macos-Monterey-Ventura-x86_64-Release.dmg`
- Windows: `gridcoin-5.5.3.0-win64-setup.exe`

## Naming
- Pattern: `<pkg>_<version>.<debian-codename>-1_<arch>.deb`, version `5.5.3.0` (four-part).
- Arch suffixes: amd64, arm64, armhf, i386.

## Body notes
- Docker mentioned: healthcheck runs as daemon account; RPC stays on loopback unless `GRC_RPC_ALLOW_SUBNET` is set.
- Flatpak RPC: `flatpak run --command=gridcoinresearchd us.gridcoin.GridcoinResearch <command>`.
- Debian/Ubuntu packages switch services to new systemd units on upgrade.
- No explicit glibc or OS minimum stated.
