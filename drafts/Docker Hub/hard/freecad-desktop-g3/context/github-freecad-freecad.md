# FreeCAD/FreeCAD (application source and releases)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/FreeCAD/FreeCAD/main/README.md (fetched 2026-11-26, WebFetch summary)
- https://github.com/FreeCAD/FreeCAD/releases (fetched 2026-11-26, first page only)

What it is: FreeCAD, an open-source parametric 3D modeler (Windows, macOS, Linux). Built on OpenCASCADE (geometry kernel), Coin3D (scene graph), Qt (GUI), Python (scripting API).

Install/build steps: the README points to the Developers Handbook "Getting Started" for compile instructions. No full build dependency list was in the fetched text. Install options named on the project pages: precompiled stable packages on GitHub latest releases, distro software centres, weekly development builds on GitHub releases.

Runtime deps: not listed in the fetched text.

License: not stated in the fetched README (only "open-source"). Plan.md says LGPL-2.1-or-later, which is UNVERIFIED here.

Version/release info and asset naming (releases page, first page):
- No stable release is shown on the first page; every entry is flagged "Pre-release".
- Entries seen: weekly-2026.11.26 (newest), weekly-2026.11.25, weekly-2026.11.18, weekly-2026.11.11, weekly-2026.11.04, weekly-2026.10.28, weekly-2026.10.21, weekly-2026.10.14, `26.3rc2` (released 18 Oct, commit 9fb16e7, final "targeted for November"), `26.3rc1` (released 8 Oct).
- The page says there are 14 pages of releases, so the stable 1.1.x release (which plan.md says is 1.1.4) was not visible here.
- Asset file names were not visible (asset list failed to load). The page advises Linux users to open the `*.AppImage`.
- Upstream accetto Dockerfile builds the AppImage URL as `https://github.com/FreeCAD/FreeCAD/releases/download/${FREECAD_VERSION}/${FREECAD_APPIMAGE}`, i.e. the AppImage is hosted on GitHub releases under the tag name.

Arch support: Linux AppImage, aarch64 and x86_64 names not confirmed in fetched text.

Gotchas:
- plan.md says "Version 1.1.4 (latest stable per freecad.org downloads)". freecad.org links to "Release_notes_1.1" which supports a 1.1 line, but the first GitHub releases page shows only pre-releases, so 1.1.4 is UNVERIFIED against GitHub. Renovate `versioning=loose` must skip `26.3rc*` and `weekly-*`.

Failed to fetch: none.
