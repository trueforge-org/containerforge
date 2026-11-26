# github.com/Cisco-Talos/clamav (source repo, release clamav-1.5.5, COPYING)

Source URL(s) + fetch date:
- https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.5 · fetched 2026-11-26 (partial: asset list failed to load)
- https://raw.githubusercontent.com/Cisco-Talos/clamav/main/COPYING.txt · fetched 2026-11-26
- https://github.com/Cisco-Talos/clamav/ (repo root, via release and COPYING) · fetched 2026-11-26

## What it is
ClamAV: open-source antivirus engine (signatures, daemon clamd, scanner clamscan, updater freshclam). Cisco Talos maintains it.

## Version / release info
- Release tag `clamav-1.5.5`, marked **Latest**, published 18 Nov (year not shown on page; clamav.net file timestamps are 2026-11-17). Commit `fef3d62`. Published by `val-ms`.
- Assets: the page reports "Assets 26" but the list failed to load ("Uh oh! There was an error while loading"). Asset names and SHA256 digests are NOT confirmed from this page.
- Asset naming pattern (confirmed on clamav.net listing, see clamav-net-downloads.md): `clamav-<version>.linux.x86_64.deb` and `clamav-<version>.linux.aarch64.deb` (plus `.rpm` and `.deb.sig` files).
- GitHub download pattern (from plan/draft): `https://github.com/Cisco-Talos/clamav/releases/download/clamav-<version>/clamav-<version>.linux.<x86_64|aarch64>.deb`. Pattern consistent with clamav.net, but the GitHub asset itself was not verified.

## License
COPYING.txt: GNU GENERAL PUBLIC LICENSE Version 2 (June 1991), with a "REGARDING OPENSSL" section that permits linking with OpenSSL (OpenSSL linking exception, per source file conditions). The text does not settle "only" vs "or later" for ClamAV itself (no per-project notice fetched). Plan's `GPL-2.0-only` therefore remains a judgement; see README.

## Build deps / runtime deps / entrypoint
Not in this source (see github-cisco-talos-clamav-docker.md for the upstream image build).

## Checksums
None published on the release page that could be read. See clamav-net-downloads.md (no SHA256 on clamav.net; `.sig` detached signatures instead).
