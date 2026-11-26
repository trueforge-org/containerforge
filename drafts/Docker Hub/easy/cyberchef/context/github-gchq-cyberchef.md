# gchq/CyberChef (repository, README, releases)

Source URL(s) + fetch date:
- https://github.com/gchq/CyberChef (README via raw master) · 2026-11-26
- https://github.com/gchq/CyberChef/releases/latest · 2026-11-26
- https://github.com/gchq/CyberChef/releases/expanded_assets/v11.6.0 · 2026-11-26

## What it is
"The Cyber Swiss Army Knife": a web app for data operations (encodings, encryption, hexdumps, compression, hashes, IPv6/X.509 parsing, charset conversion) run in the browser.

## Install/build steps and build deps
- Source build requires Node.js v24 (supported on v24, tested on v26; `.nvmrc` included).
- Steps: clone, `npm install`, `npm run build` (production build into `build/prod`).
- Other commands: `npm start` (dev server on `http://localhost:8080`), `npm test`, `npm run testui`, `npm run lint`, `npm run setheapsize` (raises Node heap if build runs out of memory).

## Runtime
- Entirely client-side. No server component, no recipe/input sent to the server. Static files only.
- Browser support: Chrome 50+, Firefox 38+. File input up to about 2GB.
- Deep links use the URL hash: `#recipe=...&input=...&theme=...`.

## Binaries/entrypoint/CLI flags
- None. Static web app.

## Env vars / config
- None documented.

## Ports
- README's Docker example serves on 8080 (`docker run -p 8080:8080`).

## Version/release info and asset naming
- Latest release: `v11.6.0` (marked Latest), published 20 Nov (no year shown). Tag is signed (GPG). Tag commit: `f464d62c7c943cda9749a765932a7548ba9bfb16`.
- Standalone zip asset name contains the tag commit: `CyberChef_f464d62c7c943cda9749a765932a7548ba9bfb16.zip` (79.6 MB).
- Expanded assets page lists three assets: the zip above, `Source code (zip)`, and `Source code (tar.gz)`. Only the zip shows a size and digest.
- Zip sha256 (from expanded_assets page): `6b6518c620d43776c19bf5cea1fd4a505b018bc829f7e88f7f77be38d64598d9`.
- The `releases/latest` page's asset list failed to load in the fetch; the expanded_assets page gave the asset list.
- Five commits on master since the release (per releases page).
- Live website shows a dev build `3aa9805f30d883bce62a168c80d96966be357a5d` (built 26/11/2026). This is NOT the release; do not use it for versioning.

## Arch support
- Not stated; the bundle is browser/JS, so architecture-independent.

## License
- Apache-2.0, © Crown Copyright 2016-2026.

## Gotchas
- Release zip has the commit sha in its name, so the asset URL cannot be derived from the tag alone. The commit is the peeled tag commit.
- Older `v11.5.0` zip (draft link) is `CyberChef_8cd426dd4f40f1423912d5fad91b578a86a65112.zip` (from plan.md, not re-verified here).
