# GitHub: YOURLS/YOURLS (upstream app) and config sample

## Source URL(s) + date
- https://github.com/YOURLS/YOURLS/releases/latest (HTML, 2026-11-27; used as fallback)
- https://raw.githubusercontent.com/YOURLS/YOURLS/master/user/config-sample.php (2026-11-27)
- Not fetched: https://api.github.com/repos/YOURLS/YOURLS, /releases, /releases/latest (API returned HTTP 403 rate limit; one alternative used, then stopped).
- Not fetched: https://github.com/YOURLS/YOURLS repo root (covered by releases/config).

## What it is
- YOURLS, PHP URL shortener, MIT licensed (per docs footer: code MIT, docs CC BY 4.0).

## Version / asset naming
- Latest release: `1.10.6` ("Release 1.10.6 · YOURLS/YOURLS").
- Source tarball used by image: `https://github.com/YOURLS/YOURLS/archive/${YOURLS_VERSION}.tar.gz` (tag without `v` prefix). Upstream tar extracts to `YOURLS-<ver>/`.
- No release asset list captured (API 403).

## Config file (user/config-sample.php)
| Constant | Default in sample |
| --- | --- |
| YOURLS_DB_USER | 'your db user name' |
| YOURLS_DB_PASS | 'your db password' |
| YOURLS_DB_NAME | 'yourls' |
| YOURLS_DB_HOST | 'localhost' |
| YOURLS_DB_PREFIX | 'yourls_' |
| YOURLS_SITE | 'https://your-own-domain-here.com' (no trailing slash) |
| YOURLS_LANG | '' |
| YOURLS_UNIQUE_URLS | true |
| YOURLS_PRIVATE | true (admin behind login) |
| YOURLS_COOKIEKEY | placeholder, must be random |
| YOURLS_URL_CONVERT | 36 |
| YOURLS_DEBUG | false |

## Gotchas
- Sample is 97 lines; the image ships its own `config-container.php` (see template file) instead of editing this file.
