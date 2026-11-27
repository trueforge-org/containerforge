# Ubuntu package libapache2-mod-musicindex (resolute)

Source URL(s) + date: https://packages.ubuntu.com/resolute/amd64/libapache2-mod-musicindex/download and .../resolute/arm64/libapache2-mod-musicindex/download (fetched 2026-11-27)

## Version / assets
- Package: `libapache2-mod-musicindex_1.4.1-6` (amd64 and arm64 .deb both listed for Ubuntu `resolute`).
- Pool path as printed on page: `pool/universe/liba/libapache-mod-musicindex/` (page spells the dir without the "2"; use the file name as the source of truth).
- Mirrors listed (e.g. mirrors.kernel.org/ubuntu, ftp.osuosl.org/pub/ubuntu). Page advises apt over manual download.
- Component: universe. Suite: resolute.

## Failures
- https://packages.ubuntu.com/resolute/libapache2-mod-musicindex (package overview): connection failed (no HTTP status, curl 000). Alternative used: the /amd64/.../download page (200).

## Gotchas
- Only the amd64 and arm64 download pages were read. Dependencies (apache2 module ABI) and file list not fetched.
