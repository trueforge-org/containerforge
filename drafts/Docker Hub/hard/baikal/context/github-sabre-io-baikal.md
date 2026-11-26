# sabre-io/Baikal (upstream application)

**Source URL(s) + fetch date:** https://github.com/sabre-io/Baikal (raw `master/README.md`, raw `0.13.0/composer.json`, https://github.com/sabre-io/Baikal/releases/latest). Release zip `https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip` recorded, not downloaded (see README.md). · fetched 2026-11-26

## What it is
"Lightweight CalDAV+CardDAV server" with a web admin interface, built on sabre/dav. Developed by Net Gusto and fruux with community contributors. Clients: iOS, macOS, DAVx5, Thunderbird.

## Install/build steps and build deps
- Download the latest zip from the Baikal releases page, unpack, upload.
- Make `Specific` and `config` writable by the web server.
- Open the installer at `http://<server>/baikal/html/` and follow the wizard (per sabre.io install page; see sabre-io-baikal-docs.md).
- Pure PHP; no build step needed for the release zip.

## Runtime deps
- composer.json (0.13.0): `php ^8.2`; ext-dom, ext-pdo, ext-zlib.
- Database: MySQL, PostgreSQL or SQLite.
- Web server: Apache or Nginx; `html/` is the docroot.

## Binaries/entrypoint/CLI flags
None (PHP web app). Tests use `php -S` and `run_tests.py` (repo README, not for the image).

## Config files and formats
Config is in the `config` directory (the wizard writes config). `Specific` holds the SQL database (SQLite) and must not be web-accessible. The exact config file name was not confirmed by these fetched pages (plan.md's `config/baikal.yaml` is not confirmed here).

## Env vars
None documented by the app.

## Ports
No default port stated. Sample Nginx server block on port 80; Apache sample on 443.

## Volumes/paths
`config` and `Specific` must be writable (per install page).

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- Latest release `0.13.0`, marked Latest, 19 Oct, commit `aa219e5` (verified signature), published by ByteHamster. Year not shown.
- Release notes: fixes calendar sharing on older SQLite installs (back up first), emoji encoding on MySQL, jQuery URL on login page; bundles sabre/dav 4.7.1.
- Release has 3 assets; names did not load. Zip name pattern `baikal-<version>.zip` (from the download URL format used by the wrapper).
- Tags are bare (`0.13.0`, no `v` prefix), per plan.md.

## Licence
GPL-3.0-only (composer.json `license` field, 0.13.0; README says GNU GPL v3).

## Gotchas
- Install page says PHP version is in composer.json (no version on the page) — composer.json says ^8.2.
- Test suite resets config and DB; never run on a real install.

## Contradictions with plan.md
- plan.md section 1 PHP requirement `php ^8.2 with dom, pdo, zlib`: confirmed.
- plan.md section 1 licence GPL-3.0-only: confirmed.
- plan.md section 1 Version 0.13.0 published 19 Oct: confirmed (year not shown).
