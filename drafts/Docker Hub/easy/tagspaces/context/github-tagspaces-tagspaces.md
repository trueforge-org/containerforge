# tagspaces/tagspaces (upstream repo; release v6.15.1)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/tagspaces/tagspaces/v6.15.1/LICENSING.md
- https://raw.githubusercontent.com/tagspaces/tagspaces/v6.15.1/README.md
- https://raw.githubusercontent.com/tagspaces/tagspaces/v6.15.1/package.json
- https://github.com/tagspaces/tagspaces/releases (asset list partial)

## What it is
Free, open-source platform for organising, tagging and managing local files (Electron desktop, web, mobile builds). Works offline. Tags are stored in filenames or sidecar files. Dual-licensed: AGPL-3.0 core, commercial licence available from TagSpaces GmbH; Pro components are proprietary (EULA). Not optimised above 100,000 files (README).

## Install/build steps
- Web version (README): clone, `npm install`, `npm run run-web`.
- package.json scripts for web (names): `build:web`, `build:web:dev`, `prepare-web`, `prepare-web-pro`, `copy-web`, `package-web`, `package-web-pro`, `run-web`, `run-web-aws`, `run-web-dev`, `run-web-extensions`, and others. `build:web` is the production webpack build; `package-web` produces the zipped web output (the release's `tagspaces-web-<version>.zip` per plan.md; the zip itself was not fetched).
- Desktop: `npm run package-win`, `package-linux`, `package-mac`, `package-mac-arm64`.
- Mobile: Capacitor, `run-android-cap`, `run-ios-cap`.
- No Docker instructions in the README (a `docker/` folder exists in the project structure, per README).

## Runtime deps
Browser (the web build). No server-side runtime; the README says the desktop worker opens no network port. No env vars required (README: worker needs no key or `.env`).

## Binaries/entrypoint/CLI flags
None for the web build (static bundle).

## Env vars
None documented for the web build (README).

## Ports
None documented (README).

## Volumes/paths and persistent data
Data is local files; no server data path. Storage location for the web build is not stated on the fetched pages.

## User/UID & permissions
N/A.

## Config files and formats
Tags in filenames or sidecar files (docs). `extconfig.js` in the web bundle per plan.md (not fetched).

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- Releases page: v6.15.1 (16 Nov) marked Latest; v6.15.0 (08 Nov) pre-release; v6.14.3 (13 Oct); v6.14.1 (06 Oct); v6.14.0 (04 Oct); v6.13.12 (20 Jul); v6.13.11 (08 Jul); v6.13.9 (30 Jun); v6.13.4 (23 Jun, pre-release); v6.13.3 (20 Jun).
- v6.15.1 visible assets (19 total, partial): `SHA256SUMS.txt`, `tagspaces-android-6.15.1.apk`, `tagspaces-linux-amd64-6.15.1.deb`, `tagspaces-linux-arm64-6.15.1.AppImage`, `tagspaces-linux-arm64-6.15.1.deb`, `tagspaces-linux-arm64-6.15.1.tar.gz`, `tagspaces-linux-x64-6.15.1.tar.gz`, `tagspaces-linux-x86_64-6.15.1.AppImage`, `tagspaces-mac-arm64-6.15.1.dmg`, `tagspaces-mac-arm64-6.15.1.pkg`, source zip and tar.gz.
- `tagspaces-web-6.15.1.zip` is not in the visible part of the list (may be among the hidden assets). plan.md says it returned HTTP 200; not re-checked here.
- SHA256SUMS.txt is a visible asset (plan.md's checksum source), consistent with plan.md.

## Arch support
Desktop assets per arch (amd64, arm64, x64, x86_64). Web bundle is arch-independent (plan.md's reasoning; no arch info on the page).

## License
AGPL-3.0 (package.json `"license": "AGPL-3.0"`; LICENSING.md: core under AGPL-3.0 with LICENSE.txt; every core source file header names AGPL-3.0). LICENSING.md: Lite packages hold only the AGPL core. Pro (`tagspacespro/`) is proprietary, not under the AGPL. Whether the header says "-only" or "-or-later" was not seen in the fetched text.

## Gotchas
- Pro builds are proprietary; `tagspaces-pro-web-*.zip` must not be used (plan.md).
- Contributors sign a CLA before PRs (README).

## Contradictions with plan.md
- plan.md's "web/LICENSE.txt is the AGPL v3 text": consistent with LICENSING.md, not checked inside the zip.
- None on version (6.15.1 is the latest, 16 Nov, matches plan.md).
