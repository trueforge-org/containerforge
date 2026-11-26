# tinyMediaManager download page and release host

**Source URL(s):** https://www.tinymediamanager.org/download/ (fetched); https://release.tinymediamanager.org/ (followed, the release host the download page points to)
**Fetched:** 2026-11-26

## Current stable
- Version 5.3.5 (listed under v5). Build timestamps 2026-10-30 (about 2:03 to 2:06 PM).

## Linux downloads (labelled "Universal Package", `.tar.xz`)
- amd64: `tinyMediaManager-5.3.5-linux-amd64.tar.xz`, 131.5 MB.
- arm64: `tinyMediaManager-5.3.5-linux-arm64.tar.xz`, 130.3 MB.
- Both under the relative path `v5/dist/`.
- URL pattern (plan.md verified): `https://archive.tinymediamanager.org/v<VER>/tinyMediaManager-<VER>-linux-<ARCH>.tar.xz`; older versions kept at archive.tinymediamanager.org; current release at release.tinymediamanager.org.
- Checksums: each download has a "sha256" link (plan.md says `<tarball>.sha256` sidecar, 64 hex chars, no filename). The file name/URL was not confirmed here.
- Per plan.md: amd64 sha256 `5901310291318bbbf0768d79dc859b4e8bb3151806fb00231c5b8ddd81aac24e`, arm64 `807a0183aae39bdc936af791b7c89ceee5576f0ffaefc709664c5174f3dcff37` (plan's own verification, not re-fetched here).

## Other downloads (not used)
- Windows: Installer (.exe), Portable (.zip). macOS: aarch64 and x86_64 .dmg. Docker (amd64, arm64) link to Docker Hub.

## Channels
Release, Pre-Release, Nightly Build.

## License/cost
Downloadable and evaluable free with some limitations (link to /purchase/). The page does not name a formal license; GitLab and the Dockerfile label say Apache-2.0.

## Gotchas
- The download page labels arm64 as a normal Universal Package; the install docs say ARM builds have no bundled JRE (see docs-tinymediamanager-installation.md).
- No directory listing of files on release host; download links only.
