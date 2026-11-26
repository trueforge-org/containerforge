# sabre.io/baikal docs (install and intro)

**Source URL(s) + fetch date:** https://sabre.io/baikal/ and https://sabre.io/baikal/install/ · fetched 2026-11-26

## Intro (https://sabre.io/baikal/)
- Lightweight CalDAV and CardDAV server with web admin, built on sabre/dav.
- Databases: MySQL, PostgreSQL, SQLite. Clients: iOS, Mac OS X, DAVx5, Thunderbird, any CalDAV/CardDAV client.
- Requirement: "basic php capable server" (no version on this page).
- Links: install https://sabre.io/baikal/install/, Docker (unofficial) https://sabre.io/baikal/docker-install/, troubleshooting https://sabre.io/baikal/troubleshooting/, upgrade https://sabre.io/baikal/upgrade/, releases https://github.com/sabre-io/Baikal/releases/latest.

## Install (https://sabre.io/baikal/install/)
1. Download the latest zip from the GitHub releases page.
2. Unpack and upload to the server.
3. Make `Specific` and `config` writable by the web server (e.g. `chown -R www-data:www-data Specific config`).
4. Open `http://yourserver.example.org/baikal/html/` and follow the wizard.

- Docroot: `html/`. Other directories should be blocked; `Specific` must not be directly reachable (it may hold the SQLite DB).
- Sample Nginx server block: port 80; denies `.ht`, `Core`, `Specific`, `config`; passes PHP to php-fpm via unix socket. Sample Apache: port 443 with SSL.
- Both samples redirect `/.well-known/caldav` and `/.well-known/carddav` to `/dav.php` (Apache uses 308).
- PHP extensions and exact PHP version are not named on the install page (composer.json is the source: `^8.2`, see github-sabre-io-baikal.md).
- Config file name is not given on this page.

## Gotchas
- Install page describes the docroot as `html/`; plan.md's chosen docroot should match this.
