# ofeefee/fluttercoin (upstream project README)

Source URL: https://raw.githubusercontent.com/ofeefee/fluttercoin/master/README.md (fetched 2026-11-27)

## What it is
- Flutter Coin (FLT): scrypt PoW/PoS hybrid with "Proof-of-Transaction" (POT).
- Default P2P port 7408; default RPC port 7474.

## Build
- Official builds from gitian; manual build uses makefile.linux (not makefile.unix).
- Old deps listed: openssl-1.0.1g, db-6.0.20.NC, miniupnpc-1.8, zlib-1.2.8, libpng-1.6.8, qrencode-3.4.3, boost_1_55_0, qt-everywhere 4.8.3.
- No maximum coin supply claim beyond ~225M estimate.

## Gotchas
- README build deps are Qt4-era; the ich777 image uses libqtgui4 runtime.
- Reward schedule table in README not reproduced (not needed for build).
