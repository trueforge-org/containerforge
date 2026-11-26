# bitcoin/bitcoin (upstream source)

**Source URL(s) + fetch date:** https://github.com/bitcoin/bitcoin (raw `master/README.md`) · fetched 2026-11-26

## What it is
Bitcoin Core: connects to the Bitcoin P2P network, downloads and validates blocks and transactions; bundles a wallet and an optional GUI.

## Licence
MIT (repo `COPYING` has the full terms; not fetched).

## Build pointers
Build instructions in `doc/build-*.md`. `master` is regularly built and tested but may not be fully stable. Other docs: `doc/developer-notes.md`, `doc/translation_process.md`, `CONTRIBUTING.md`, Python functional tests in `/test`.

## Downloads
Binary downloads listed at https://bitcoincore.org/en/download/ (see `bitcoincore-org-download-and-checksums.md`).

## Gotchas
- README does not give Docker, datadir or port details.
- Tags are `v<version>` (for example `v32.1`, which the raw release-notes path resolved).
