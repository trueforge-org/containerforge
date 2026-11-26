# friendica/friendica (application source, 2026.05)

Source URL(s) + fetch date:
- https://github.com/friendica/friendica (repo, referenced by draft; not fetched directly)
- https://raw.githubusercontent.com/friendica/friendica/2026.05/composer.json (2026-11-26, WebFetch summary)
- https://github.com/friendica/friendica/releases/tag/2026.05 (2026-11-26, WebFetch summary)

What it is: Friendica, a decentralised social network (ActivityPub, OStatus, diaspora*), PHP with MySQL/MariaDB.

composer.json (tag 2026.05):
- `require.php`: `7.4.* || 8.0.* || 8.1.* || 8.2.* || 8.3.* || 8.4.* || 8.5.*`, so PHP 8.5 is supported by the app. This resolves plan.md's PHP 8.5 open question.
- Required extensions: ext-apcu, ext-ctype, ext-curl, ext-dom, ext-fileinfo, ext-gd, ext-gmp, ext-iconv, ext-imagick, ext-json, ext-libxml, ext-mbstring, ext-openssl, ext-posix, ext-simplexml, ext-xml.
- License field: `AGPL-3.0+` (i.e. AGPL-3.0-or-later).

Release tag 2026.05 (github.com/friendica/friendica/releases/tag/2026.05):
- Tagged by tobiasd, commit 285cc57, tag message "bump version 2026.05", created 20 May.
- No release notes text on the page. The page reports 2 assets but the list did not load, so asset names (tarballs, .asc, .sum256) are not confirmed here. The upstream Docker build uses the all-in-one tarball from files.friendi.ca (see the docker file).

Version info: latest stable 2026.05 ("Blutwurz", announced 21 May 2026, per friendi.ca). A 2026.08 release candidate exists.

Gotchas: plan.md says the GitHub release `2026.05-1` is the latest; this page is for the `2026.05` tag, so the `-1` suffix was not checked here.

Failed to fetch: none. Assets list failed to load on the release page.
