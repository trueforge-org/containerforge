# github.com/Ultimaker/Cura (source, release 5.14.0, LICENSE, wiki)

Source URL(s) + fetch date:
- https://github.com/Ultimaker/Cura/releases/latest · fetched 2026-11-26
- https://raw.githubusercontent.com/Ultimaker/Cura/main/README.md · fetched 2026-11-26
- https://raw.githubusercontent.com/Ultimaker/Cura/main/LICENSE · fetched 2026-11-26
- https://github.com/Ultimaker/Cura/wiki/Getting-Started · fetched 2026-11-26 (developer page; no end-user install content)
- https://github.com/Ultimaker/Cura (repo root, via README and releases) · fetched 2026-11-26

## What it is
UltiMaker Cura: open-source 3D-printing slicer ("400+ customizable settings"). Free. Stable 5.14 per website.

## Release / version
- Latest release **5.14.0**, marked Latest, published 05 Nov (github-actions, commit `16c219e`). Year not shown.
- Assets: "Assets 12" but the asset list failed to load (error on page). No Linux asset names, sizes or checksums confirmed from GitHub.
- Linux asset name (from the website): `UltiMaker-Cura-5.14.0-linux-X64.AppImage` with `.AppImage.asc` signature (matches plan/draft naming). Linux is **x64 only** (no arm64 AppImage).

## Licence
LICENSE: GNU Lesser General Public License Version 3, 29 June 2007. Section 6 says that if the Library specifies "or any later version", the user may follow that version or any later FSF version; if it specifies none, any published version may be chosen. The "or later" choice is therefore a property of how Cura declares its licence (README/headers), not of the LICENSE file alone. README badge: LGPL3. Third-party license list linked.

## Platforms (README and website)
Mac (Intel and Apple Silicon, .dmg/.pkg), Windows (x64 and ARM64, .exe/.msi), Linux x64 only (AppImage).

## Developer / build notes (Getting Started wiki)
- Build from source via Conan and a virtualenv; recommended IDE PyCharm; first `conan install` can take over 30 minutes. Conan cache in `~/.conan`. Do not run conan with sudo.
- External CuraEngine dev: `--external-backend`, `curaengine connect 127.0.0.1:49674` (port appears in logs).
- Wiki does NOT cover AppImage/FUSE, end-user install, settings locations (`~/.config/cura` is on a separate "Cura Preferences and Settings Locations" page, linked but not fetched) or OpenGL requirements ("Running Cura from Source" page, not fetched).

## Gotchas
- No system OpenGL requirement is stated on any fetched page (plan.md's "OpenGL 4.1+" remains UNVERIFIED).
