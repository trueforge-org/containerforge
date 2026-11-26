# amacneil/docker-bitcoin, unlimited/1.1.1.1/Dockerfile

Source: https://raw.githubusercontent.com/amacneil/docker-bitcoin/master/unlimited/1.1.1.1/Dockerfile (fetched 2026-11-26)

## Build facts (pinned to BU 1.1.1.1)
- Base: `debian:stretch-slim`
- ENV: `BITCOIN_VERSION=1.1.1.1`
- ENV: `BITCOIN_URL=https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/raw/master/BUcash-1.1.1.1-linux64.tar.gz`
- ENV: `BITCOIN_SHA256=bdc3e07ce2cacc42295d7559fbaae5ae60fed82479c5644ab7293bbea6b79a62`
- ENV: `BITCOIN_DATA=/data`
- ARG: none

## Steps
1. `groupadd -r bitcoin`; `useradd -r -m -g bitcoin bitcoin`
2. apt-get update; install `--no-install-recommends`: ca-certificates, dirmngr, gosu, gpg, wget; then remove /var/lib/apt/lists/*
3. In /tmp: `wget -qO bitcoin.tar.gz $BITCOIN_URL`; `sha256sum -c` against $BITCOIN_SHA256; `tar -xzvf` into /usr/local with `--strip-components=1`, excluding `*-qt`; clear /tmp
4. `mkdir $BITCOIN_DATA`; chown bitcoin:bitcoin; symlink /home/bitcoin/.bitcoin -> /data; `chown -h`
5. COPY docker-entrypoint.sh -> /entrypoint.sh

## Runtime
- ENTRYPOINT `["/entrypoint.sh"]`; CMD `["bitcoind"]`
- No USER instruction (container starts as root; gosu present, so entrypoint presumably drops privileges; script not fetched)
- EXPOSE 8332 8333 18332 18333
- VOLUME /data

## Gotchas
- Binary is a prebuilt tarball, not compiled; the `-qt` GUI is excluded
- Upstream URL points to BitcoinUnlimitedWebDownloads repo (binary download, not to be mirrored here)
