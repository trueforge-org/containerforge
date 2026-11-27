# audacity/audacity: latest release + README

Source URL(s) + date: https://api.github.com/repos/audacity/audacity/releases/latest (fetched 2026-11-27); https://raw.githubusercontent.com/audacity/audacity/master/README.md (fetched 2026-11-27). Repo HTML and /releases/latest HTML covered by these.

## Latest release (API)
- tag_name `Audacity-4.0.2`, name "Audacity 4.0.2", published 2026-11-02T10:01:34Z.
- Assets:
  - `audacity-linux-4.0.2-x86_64.AppImage`, `audacity-linux-4.0.2-aarch64.AppImage`
  - `audacity-macOS-4.0.2-arm64.dmg`, `-universal.dmg`, `-x86_64.dmg`
  - `audacity-win-4.0.2-x86_64.msi`, `-arm64.msi`, `-x86_64.7z`, `-arm64.7z`
  - `audacity-sources-4.0.2.tar.xz`
  - `CHECKSUMS.txt` (sha256 per asset)
- Naming differs from pre-4 `audacity-minsrc-<ver>.tar.xz` used by the old pinned Dockerfile.

## README (upstream)
- Audacity: multi-track audio editor and recorder for Windows, macOS, GNU/Linux.
- Audacity 4 under development on `master`; 3.x patches go to `audacity3` branch.
- Build docs: BUILDING.md in repo (master for 4.x; release-3.7.0 for 3.x).
- License: GPLv3 overall; most code GPLv2-or-later; exceptions in `au3/lib-src` (third-party) and VST3 code; docs CC-BY 3.0. Full text in LICENSE.txt.
- GitHub API reports license NOASSERTION (not SPDX-parsed).

## Gotchas
- Release 4.0.2 is a major line change from the chart's 3.0.2.
