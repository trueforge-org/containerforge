# vrana/adminer (upstream source)

**Source URL(s):** https://github.com/vrana/adminer (README via https://raw.githubusercontent.com/vrana/adminer/master/README.md; releases via https://github.com/vrana/adminer/releases)
**Fetched:** 2026-11-26

## What it is
- Full-featured database management tool written in PHP, delivered as a single file that is uploaded to a web server.
- Adminer Editor is a variant for end-user data manipulation.
- Official site: https://www.adminer.org/
- Built-in drivers: MySQL, MariaDB, PostgreSQL, CockroachDB, SQLite, MS SQL, Oracle. Plugin-based: Elasticsearch, OpenSearch, SimpleDB, MongoDB, Redis, Firebird, ClickHouse, IGDB, IMAP.

## Install/build steps and build deps
- Compiled single-file version is produced by `compile.php` (source tree). Container use needs only the release file.
- Source checkout: `git submodule update --init` or `composer install`.
- No build step needed for a container that uses the release `adminer-<ver>.php` asset.

## Runtime deps
- PHP: the compiled single file needs PHP 5.4+ (README). Source needs PHP 7.4+.
- Session support must be enabled (adminer.org).
- Per-database PHP extensions are not listed in the upstream docs. The upstream Docker image (see github-timwolla-docker-adminer.md) installs mysqli, pdo_pgsql, pdo_sqlite (and pdo_odbc, pdo_dblib in the alpine image).

## Binaries/entrypoint/CLI flags
- No CLI. Run it as a web page: the PHP file is served by any PHP-capable web server.
- Release assets (v6.3.1, from the plan's verification; the asset list did not load in this fetch): `adminer-6.3.1.php` (all drivers), `-en` (English only), `-mysql` (MySQL only), `-mysql-en`, `.zip`, `editor-6.3.1.php`.
- Asset URL pattern: `https://github.com/vrana/adminer/releases/download/v<VER>/adminer-<VER>.php` (tag has `v` prefix, filename does not).
- Latest release at fetch time: tag `v6.3.1` (marked Latest, published 20 Nov, commit 07e42f0).
- The release page does not publish a checksum (per plan.md verification).

## Env vars
None read by `adminer.php` itself (README and adminer.org document none). `ADMINER_DEFAULT_SERVER`, `ADMINER_DESIGN`, `ADMINER_PLUGINS` belong to the TimWolla Docker wrapper, not to Adminer. See github-timwolla-docker-adminer.md.

## Ports
None set by upstream. Web server decides. Docker image uses 8080 (see docker-adminer summary).

## Volumes/paths and persistent data
- None defined upstream. Plugins and designs are optional: a design is a CSS file `adminer.css` or `adminer-dark.css` placed next to `adminer.php`. Plugins are PHP files loaded from a plugin directory (wrapper-specific).
- Designs and plugins live in the source tree at `designs/` and `plugins/` (the TimWolla image downloads them from the source tarball).

## User/UID and permissions
Not specified upstream.

## Config files and formats
- Single PHP file. Login/customization is done by extensions (plugins) or by overriding the `login` method.
- Plugin loader: `plugins/` in source, `plugin-loader.php` in the Docker wrapper.

## Healthcheck/readiness endpoints
None specified upstream. A `GET /` returning HTML is the only readiness signal.

## Version/release info and asset naming
- Releases are tagged `vX.Y.Z`; latest seen: v6.3.1 (20 Nov). v6.3.0 (3 Nov) noted "Require PHP 5.4+".
- v6.3.1 notes mention PHP-version-specific fixes: PostgreSQL NUL-in-password crash (PHP 8.5.13); SQLite ATTACH/VACUUM INTO restriction without authorizer (PHP < 8.0, PDO < 8.5); SQLite PDO file: URI support (PHP 8.1+).
- Renovate: `datasource=github-releases depName=vrana/adminer` (plan.md).

## Arch support
Arch-neutral single PHP file. Platform-specific desktop builds (Windows, macOS Apple Silicon, Linux) exist upstream but are not relevant to the container.

## Gotchas
- Adminer refuses logins without a password and rate-limits connection attempts (adminer.org).
- Upstream recommends limiting public access: IP allowlist, web-server password protection, security plugins, or custom `login` method. Delete the file when unused.
- Adminer has had security bugs in the past; keep it updated.
- License: Apache-2.0 OR GPL-2.0-only (repo LICENSE and file header).
- A single PHP file has no bundled DB server; a database must be reachable separately.
