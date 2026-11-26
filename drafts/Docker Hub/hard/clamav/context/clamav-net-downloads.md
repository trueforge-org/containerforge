# clamav.net/downloads (official downloads page)

Source URL(s) + fetch date:
- https://www.clamav.net/downloads · fetched 2026-11-26

## Current release
- Stable 1.5.5 labelled "Latest"; LTS 1.4.7 also listed.

## Linux packages for 1.5.5 (paths under https://www.clamav.net)
- amd64: `/downloads/production/clamav-1.5.5.linux.x86_64.deb` (102.6 MB)
- arm64: `/downloads/production/clamav-1.5.5.linux.aarch64.deb` (105.2 MB)
- Detached signatures per deb: `...deb.sig` (801 bytes each).
- RPMs: `clamav-1.5.5.linux.x86_64.rpm` (43.3 MB), `clamav-1.5.5.linux.aarch64.rpm` (42.1 MB).
- File timestamps 2026-11-17 (UTC); no explicit release date on the page.

## Checksums
**No SHA256 is published on this page.** Integrity is offered through the `.sig` detached signatures and the Talos PGP key at `https://www.clamav.net/downloads/gpg_public_key`. (Plan.md's "take the sha256 from clamav.net/downloads" is therefore not possible.)

## Asset naming
Same pattern as the GitHub release (`clamav-<version>.linux.<x86_64|aarch64>.deb`).
