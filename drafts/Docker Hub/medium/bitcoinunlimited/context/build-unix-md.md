# BitcoinUnlimited doc/build-unix.md

Source: https://raw.githubusercontent.com/BitcoinUnlimited/BitcoinUnlimited/master/doc/build-unix.md (fetched 2026-11-26)

## Build deps (Debian/Ubuntu apt)
- Base: build-essential libtool autotools-dev autoconf automake pkg-config libssl-dev libevent-dev bsdmainutils git
- Boost: libboost-system-dev -filesystem-dev -chrono-dev -program-options-dev -test-dev -thread-dev (fallback libboost-all-dev)
- Optional: libminiupnpc-dev (UPnP), libzmq3-dev (ZMQ 4.x), libqrencode-dev
- Wallet BDB 4.8: PPA `ppa:bitcoin-unlimited/bucash`; libdb4.8-dev libdb4.8++-dev (distro libdb 5.1+ breaks wallet compat; `--with-incompatible-bdb` to override)
- Qt GUI: libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
- Static/ARM: curl; ARM needs g++-arm-linux-gnueabihf

## Source
- `git clone https://gitlab.com/bitcoinunlimited/BCHUnlimited.git`

## Headless build (no wallet, no GUI)
- `./autogen.sh`; `./configure --disable-wallet --with-gui=no`; `make`; optional `make install`

## Full build
- `./autogen.sh`; `./configure`; `make`

## Flags
- `--without-miniupnpc`; `--enable-upnp-default` / `--disable-upnp-default` (default off)
- `--enable-hardening` (default on) / `--disable-hardening`
- `./configure --help` for rest

## Binaries
- `src/bitcoind`; `src/qt/bitcoin-qt` (if Qt deps present and GUI not disabled)
- Release: `strip bitcoind` (~90% size reduction)

## Gotchas
- Use absolute paths for configure env (BDB_PREFIX)
- >= 1 GB RAM recommended for compiling
- Without wallet, mining only via getblocktemplate (not getwork)
- Default data dir, config file, ports: not in this document
