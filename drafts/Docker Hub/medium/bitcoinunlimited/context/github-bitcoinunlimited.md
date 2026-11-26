# BitcoinUnlimited/BitcoinUnlimited (README)

Source: https://raw.githubusercontent.com/BitcoinUnlimited/BitcoinUnlimited/master/README.md (fetched 2026-11-26)

## What it is
- Open-source Bitcoin Cash client based on Bitcoin Core; daemon `bitcoind`, GUI `bitcoin-qt`
- Governed by Articles of Federation

## Install/build
- Build guides: doc/build-unix.md (see separate file), build-unix-rpm.md, build-windows.md, build-macos.md, gitian-building.md
- Dependency list: doc/dependencies.md (not fetched)

## Runtime deps
- none stated on README

## Entrypoint/flags
- none stated

## Ports / Volumes / User / Config
- none stated (init docs: doc/init.md for systemd/upstart/openrc)

## Version/asset naming
- none on README; release notes doc/release-notes.md, process doc/release-process.md
- CI badge references branch `dev`

## Gotchas
- Wallet compatibility: BerkeleyDB 4.8 required (see build-unix file)

## License
- MIT (COPYING); bundles OpenSSL, UPnP (miniupnpc) code
