# ZoneMinder README, docs index, and zmrepo apt index

## Source URL(s) + date
- https://raw.githubusercontent.com/ZoneMinder/zoneminder/master/README.md (fetched 2026-11-26)
- https://zoneminder.readthedocs.io/en/stable/ (fetched 2026-11-26; index page only)
- https://zmrepo.zoneminder.com (fetched 2026-11-26; repo landing page)
- https://zmrepo.zoneminder.com/debian/release-1.38/resolute (fetched 2026-11-26; directory listing, parsed for package names)
- https://zoneminder.com: 403 (Cloudflare challenge). One alternative `http://zoneminder.com` also 403; not retried.

## What it is (README)
- ZoneMinder: CCTV / security surveillance on Linux (capture, analysis, recording, monitoring).
- Packages: Ubuntu via Isaac Connor's PPA, Debian default repo, RPM Fusion for RHEL/Fedora.

## Docker (README)
- Official images: Docker Hub `zoneminder/zoneminder`, GHCR `ghcr.io/zoneminder/zoneminder`. Rebuilt daily from zmrepo packages.
- Tags: `latest` (newest release), `1.38`, `1.38.6` (pins), `dev` (nightly), `-es` suffix (zmeventnotificationNg event server), e.g. `1.38-es`.
- Compose via zmdockerfiles repo (MariaDB + optional object detection). UI at `http://localhost:8080/zm` in that compose.

## Package layout (zmrepo resolute index)
- `zoneminder_1.38.2-resolute1_{amd64,arm64}.deb`
- `zoneminder_1.38.3+resolute1_{amd64,arm64}.deb`
- `zoneminder_1.38.5+resolute1_{amd64,arm64}.deb`
- `zoneminder_1.38.6+resolute1_{amd64,arm64}.deb`
- Also `zoneminder-dbg_*` and `zoneminder-doc_*` (all) per version.
- Source: `zoneminder_<ver>.dsc`, `.tar.xz`, `.debian.tar.xz`.

## Docs index (readthedocs, stable)
- Sections: Installation Guide, User Guide, API, WEB UI API, FAQ, Contributing.
- Notes: many distro repos only carry older versions; check docs for install.

## Gotchas
- zmrepo is the source for 1.38.x on resolute (Ubuntu 26.04 codename) per listing above; arm64 present.
- Docs index page does not give install commands; not read further (budget).
