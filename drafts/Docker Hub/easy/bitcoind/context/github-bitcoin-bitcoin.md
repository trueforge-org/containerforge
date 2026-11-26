# bitcoin/bitcoin (Bitcoin Core source, release v32.1)

**Source URL(s) + fetch date**
- https://github.com/bitcoin/bitcoin (repo; README via raw master/README.md)
- https://raw.githubusercontent.com/bitcoin/bitcoin/v32.1/COPYING
- https://github.com/bitcoin/bitcoin/releases/tag/v32.1
- Not fetched: https://raw.githubusercontent.com/bitcoin/bitcoin/v32.1/doc/release-notes/release-notes-32.1.md (404) and the blob URL of the same file (404)
- Fetched 2026-11-26

**What it is**
- Bitcoin Core: full node that links to the Bitcoin peer-to-peer network, downloads and validates blocks and transactions. Includes a wallet and GUI, both optional at build time. Ships `bitcoind` and `bitcoin-cli` (per the kylemanna Dockerfile symlinks and the tarball layout; the README does not name them).
- License: MIT (COPYING). Copyright (c) 2009-2026 The Bitcoin Core developers and Bitcoin Developers.

**Release v32.1**
- Title "Bitcoin Core 32.1", tag `v32.1`, published 28 Oct (fanquake), marked Latest. Tag GPG-signed (key 2EEB9F5CC09526C1). Commit f0de87f.
- Page says to download from `https://bitcoincore.org/bin/bitcoin-core-32.1/` (deterministic, signed), not the GitHub-generated links.
- Release notes are in `doc/release-notes/release-notes-32.1.md` (not fetched). The plan.md claims about RPC behaviour, `-rpcmaxconnections` (16), `-maxconnections` (200), EOL of 29.x and older, and Linux 3.17 minimum could NOT be confirmed.
- Asset names not rendered on this page ("Assets 3").

**Build pointers (README)**
- Binaries at bitcoincore.org/en/download/. Build docs in `doc/build-*.md`. Unit tests via `ctest`; functional tests via `build/test/functional/test_runner.py`.

**Ports**
- Not stated in the README or release page. Defaults for mainnet (8333 P2P, 8332 RPC) are confirmed by the two upstream Dockerfiles (`EXPOSE 8332 8333`), not by the Bitcoin Core source fetched here.

**Gotchas**
- Plan.md's statement that the tarball contains `bin/` and `libexec/` (and that `test_bitcoin` lives in `libexec/`) is supported by the kylemanna Dockerfile (see github-kylemanna-docker-bitcoind.md).
