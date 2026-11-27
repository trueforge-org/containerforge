# kovidgoyal/calibre: latest release, README, license

Source URL(s) + date: https://api.github.com/repos/kovidgoyal/calibre/releases/latest (fetched 2026-11-27); https://raw.githubusercontent.com/kovidgoyal/calibre/master/README.md (fetched 2026-11-27). Repo HTML https://github.com/kovidgoyal/calibre covered by README.

## Latest release (API)
- tag_name `v9.19.0`, name "version 9.19.0", published 2026-11-21T06:12:07Z.
- Assets:
  - `calibre-9.19.0-x86_64.txz`, `calibre-9.19.0-arm64.txz`
  - `calibre-9.19.0.tar.xz` (sources)
  - `calibre-9.19.0.dmg`, `calibre-64bit-9.19.0.msi`, `calibre-portable-installer-9.19.0.exe`
- Asset URL pattern: `https://github.com/kovidgoyal/calibre/releases/download/v9.19.0/calibre-9.19.0-<arch>.txz`.

## README (upstream)
- Cross-platform e-book management; runs on Linux, Windows, macOS.
- Binaries and installers built via `bypy/README.rst`.
- License: not stated in the fetched README or releases API. The plan cites GPL-3.0 from the repo API; not verified in this fetch.

## Gotchas
- Release tag has a `v` prefix; the linuxserver Dockerfile strips it for CALIBRE_VERSION.
