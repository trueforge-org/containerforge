# bitcoincore.org: download page, SHA256SUMS, release notes, site

**Source URL(s) + fetch date:** https://bitcoincore.org/en/download/ ; https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS (signed by SHA256SUMS.asc) ; https://bitcoincore.org/ ; https://bitcoincore.org/en/doc/ ; release notes (raw, tag v32.1: https://raw.githubusercontent.com/bitcoin/bitcoin/v32.1/doc/release-notes.md) · fetched 2026-11-26

## What it is
Official Bitcoin Core downloads and documentation. Bitcoin Core: P2P node, validation, bundled wallet, optional GUI (bitcoin-qt).

## Download file naming (version 32.1)
Pattern: `bitcoin-<version>-<triple>.tar.gz` under `https://bitcoincore.org/bin/bitcoin-core-<version>/`.
- amd64: `bitcoin-32.1-x86_64-linux-gnu.tar.gz` (sha256 `61545c17c3120fb7412f896d248b11993af04ec8817aad3649c55b2afb044963`)
- arm64: `bitcoin-32.1-aarch64-linux-gnu.tar.gz` (sha256 `7ed37c7373eb6aa3e3f72842596a1afeba1b223717033cade9842b25773e1922`)
- Debug builds: `...-linux-gnu-debug.tar.gz`. Other builds: arm-linux-gnueabihf, powerpc64, riscv64, Apple, Windows.
- Source tarball `bitcoin-32.1.tar.gz` (sha256 `a5f2f61e32cf7f790641c9ec306a3c88ca7b5a556946956b1f35ffd7e27813f9`).

## Checksums
`SHA256SUMS` (full file, 27 lines; values quoted above for the two Linux tarballs). Linux instructions: `sha256sum --ignore-missing --check SHA256SUMS`, then GPG-verify `SHA256SUMS` with `SHA256SUMS.asc`. Checksums are published by the vendor (plan.md said none; this is the vendor-published checksum file).

## Version info
- Download page: "Latest version: 32.1". No release date on the page.
- Site home: recent posts announce 30.5 and 31.3 (both 20 Nov, branch maintenance releases); RPC docs list 32.0.0 as highest documented version. 32.1 is the download page's latest.
- Release notes (tag v32.1): v32.0 was tagged but never fully announced/released.

## Linux and compatibility (release notes)
- Supported on Linux kernel 3.17 or newer (also macOS 14, Windows 10 1903). No glibc minimum stated.
- Windows MSVC builds to be dropped in next major release.
- `BITCOIN_GENBUILD_NO_GIT` removed.

## Config and option changes (headless relevant)
- `-datadir`: no change noted. txindex and txospenderindex dirs under datadir can be deleted to save space.
- Port 8333: not mentioned in release notes.
- `-maxconnections` default raised 125 -> 200 (values above 2000 clamped). New `-inboundrelaypercent` (default 50). Old limits: `-maxconnections=125 -inboundrelaypercent=100`.
- New `-rpcmaxconnections` (default 16), `-prevoutfetchthreads` (default 8, max 16), `-txsendrate` (default 14 tx/s), `-walletrbf` deprecated.
- `-deprecatedrpc=startingheight` removed. `libevent` debug category removed; `mining` debug category added. `-blockmaxweight` rejected if below `-blockreservedweight`.
- RPC: libevent replaced by custom HTTP server; clients not in `-rpcallowip` disconnected immediately (no 403); PSBT RPCs default to v2; new RPCs `exportasmap`, `getopenrpcinfo`, `rpc.discover`, `addhdkey`, `exportwatchonlywallet`, `derivehdkey`.
- Estimator data file moved to `fees/block_policy_estimates.dat`.
- Versions 29.x and older are end of life.

## Docs
`https://bitcoincore.org/en/doc/` is the RPC docs index (versions 0.16.0 to 32.0.0). It does not cover headless run/datadir/bitcoin.conf. Other links: /en/releases/, /en/lifecycle, /en/security-advisories/.

## Gotchas
- Site home mentions 30.5 and 31.3 on 20 Nov (other branches). Use 32.1 (download page) for this image.
- No glibc minimum in release notes: the port's glibc base must be checked by build test.

## Contradictions with plan.md
- plan.md section 1 Version 32.1 (download page lists 32.1 as latest): confirmed.
- plan.md section 1 Checksum: "SHA256SUMS (signed...)": confirmed; plan's line is accurate.
- plan.md section 1 amd64/arm64 URLs: confirmed filenames.
- plan.md section 1 Renovate `v32.1` tag: raw content for `v32.1` tag path was served, so the tag exists.
