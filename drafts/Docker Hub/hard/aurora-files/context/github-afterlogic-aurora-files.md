# afterlogic/aurora-files (upstream application)

**Source URL(s) + fetch date:** https://github.com/afterlogic/aurora-files (raw `master/README.md`, raw `master/VERSION`, https://github.com/afterlogic/aurora-files/releases) · fetched 2026-11-26. Vendor zip https://afterlogic.org/download/aurora-files.zip is a direct download and is recorded, not fetched (see README.md).

## What it is
Open-source self-hosted cloud file storage. Accessed via browser, native clients (Windows, iOS, Android) or WebDAV clients. Includes a "Paranoid Encryption" module (browser-side AES-256; keys never sent to server).

## Install/build steps and build deps
- Stable release: download and unpack `https://github.com/afterlogic/aurora-files/archive/latest.zip` into the install root.
- Latest code: clone `https://github.com/afterlogic/aurora-files.git` and set module versions to `dev-master` in composer.json.
- Dependencies: `php composer.phar install` (run as non-root, ideally the web server user).
- Front-end: `npm install`; admin panel: `npm install` in `modules/AdminPanelWebclient/vue` plus global `@quasar/cli`; or `./builder.sh -t npm`.
- Static build: `npm run styles:build --themes=Default,DefaultDark,DeepForest,Funny,Sand`, `npm run js:build`, `npm run js:min`; admin panel `npm run build-production` in the vue folder; or `./builder.sh -t build`.
- Dev mode: rename `.env.dist` to `.env`, set Web API host, `npm run serve`; CSS `npm run styles:watch`.

## Runtime deps / requirements
- Build: Git, Composer, Node.js with NPM (above version 3).
- Runtime PHP version, extensions and DB: not stated on the README page.
- HTTPS strongly recommended (Google auth does not work over HTTP).

## Binaries/entrypoint/CLI flags
Not applicable (PHP app). Build tooling: `builder.sh` with `-t npm` / `-t build`.

## Env vars
None. Only a `.env` (from `.env.dist`) for the Web API host (for example `http://localhost/aurora/`); a non-localhost backend needs custom headers in `index.php` to avoid CORS blocks.

## Ports
None specified.

## Volumes/paths and persistent data
- `data/` directory (example `/var/www/aurora/data`) must be writable by the web server; holds configuration and user data, so it must not be web-accessible.
- Main config: `data/settings/config.json`. Setting `RedirectToHttps` to `On` enables HTTP->HTTPS redirect.
- Admin panel: `/adminpanel/`.

## User/UID & permissions
Web server user should own `data/` (example `chown -R www-data:www-data`).

## Config files and formats
`composer.json`, `.env.dist`, `data/settings/config.json`, `index.php`.

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- `VERSION` file on master: `9.8.7.build9` (exact file contents).
- GitHub releases: latest release named "9.3.1 release", tag `9.3.1`, marked Latest, 17 Mar, commit `8655ac5`, "version 9.3.1.build3". Also a `latest` tag on the same commit. Ten releases listed (9.3.1, latest, 8.2.19, 8.2.18, 8.2.17, 8.2.16, 8.2.11, 8.2.5, 8.2.4, 8.2.3). Each release shows 2 assets; names did not load.
- Tag `latest` and archive `archive/latest.zip` are moving references.

## Arch support
Not applicable (PHP).

## Licence
AGPLv3. Bundled modules and dependencies carry their own licences. Dual-licensed modules are AGPLv3 within this product.

## Gotchas
- Releases lag master: master `VERSION` is `9.8.7.build9`, latest GitHub release is `9.3.1`. Any Renovate on tags would track `9.3.1`.
- README is the only in-repo doc; config and install details are on the docs site (see `afterlogic-docs-index.md`).

## Contradictions with plan.md
- plan.md section 1 says "the repo's Releases page is empty and I could not list its tags". The releases page is NOT empty: it lists 10 releases and tags (latest `9.3.1`). Corrected in plan.md.
- plan.md section 1 `VERSION` `9.8.7.build9` on master: confirmed.
- plan.md section 1 License `AGPL-3.0`: confirmed as AGPLv3.
