# bitcoincore.org: binary downloads and checksums (32.1)

**Source URL(s) + fetch date**
- https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS (fetched 2026-11-26)
- https://bitcoincore.org/bin/bitcoin-core-32.1/ (directory listing, fetched 2026-11-26)
- Tarballs themselves (`bitcoin-32.1-x86_64-linux-gnu.tar.gz`, `bitcoin-32.1-aarch64-linux-gnu.tar.gz`) are direct archive downloads: NOT fetched. Their names and checksums are recorded here.

**SHA256SUMS (verbatim, relevant lines)**
- `61545c17c3120fb7412f896d248b11993af04ec8817aad3649c55b2afb044963  bitcoin-32.1-x86_64-linux-gnu.tar.gz`
- `7ed37c7373eb6aa3e3f72842596a1afeba1b223717033cade9842b25773e1922  bitcoin-32.1-aarch64-linux-gnu.tar.gz`
- Other Linux lines: `bitcoin-32.1-arm-linux-gnueabihf.tar.gz`, `bitcoin-32.1-powerpc64-linux-gnu.tar.gz`, `bitcoin-32.1-riscv64-linux-gnu.tar.gz` (plus `-debug.tar.gz` variants).
- macOS, Windows and `bitcoin-32.1.tar.gz` (source) lines also present.

**Directory listing (names only)**
- Checksum and signature: `SHA256SUMS`, `SHA256SUMS.asc`, `SHA256SUMS.ots`.
- Linux: `bitcoin-32.1-{aarch64,arm-linux-gnueabihf,powerpc64-linux-gnu,riscv64-linux-gnu,x86_64-linux-gnu}.tar.gz` and `-debug.tar.gz` variants.
- macOS, Windows (`.zip`, `.exe`), `bitcoin-32.1-codesignatures-32.1.tar.gz`, `bitcoin-32.1.tar.gz`, `bitcoin-32.1.torrent`.
- No subdirectories.

**Naming pattern**
- `bitcoin-<VERSION>-<ARCH>-linux-gnu.tar.gz` where ARCH is `x86_64` or `aarch64` (as used by the kylemanna Dockerfile).
- Signatures: `SHA256SUMS.asc` (signed by builder keys; the kylemanna Dockerfile lists three key fingerprints).
