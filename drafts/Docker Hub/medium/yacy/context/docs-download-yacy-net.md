# download.yacy.net (release listing)

**Source URL(s):** https://download.yacy.net/
**Fetched:** 2026-11-26

## Listing (Apache, port 443)
Latest tar.gz entries:
- `yacy_v1.942_202608150808_f9c4b9700.tar.gz`: 123 MB, 2026-08-15 08:07 (latest, the plan's target).
- `yacy_v1.941_202603291103_f0464e7fb.tar.gz`: 104 MB, 2026-03-29 11:38 (previous).

Older tarballs back to `v1.80_20140916_9000` are listed; sizes grow from 40 MB to 123 MB.

Naming pattern: `yacy_v<VERSION>_<YYYYMMDDHHMM>_<commit-short>.tar.gz`. Some old names have other suffixes (e.g. `_9000`, `_last_java_8`).

## Other asset types listed
- `.exe` Windows installers (1.942: 113 MB, 2026-08-15).
- `.dmg` macOS images (1.942: 143 MB, 2026-08-15).
- `.sig` detached signatures (64 bytes each) only for releases up to v1.922 (dated 2020-11-06). None for v1.924 onward.

## Checksums
No `.sha256`, `.sha1`, `.md5` or `.asc` files appear in the listing. The plan's checksum step must compute its own value (plan.md notes this as UNVERIFIED for upstream).

## Gotchas
- No upstream checksum: pin the SHA-256 of the downloaded file, and say so in the PR (per plan.md).
- Tarball size is about 123 MB (the image will be large).
