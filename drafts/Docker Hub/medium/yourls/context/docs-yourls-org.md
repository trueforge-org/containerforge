# YOURLS docs site (yourls.org / docs.yourls.org)

## Source URL(s) + date
- https://docs.yourls.org/ (2026-11-27, HTTP 200; fetched as fallback)
- https://yourls.org/docs/guide/requirements (2026-11-27, HTTP 404 "Page Not Found"; not retried)
- Not fetched: https://yourls.org, https://yourls.org/docs (redundant with docs.yourls.org home).

## What it is
- Official documentation portal for YOURLS. Sections: Getting started, Installation, Server configuration, Upgrade, Essentials, Extend, Advanced, Troubleshooting.

## Findings
- Home page only (JS-rendered nav; body text thin). No requirements or env details captured from this page.
- Requirements page URL from urls.txt is dead (404). Use the Dockerfile template (PHP 8.5, exts bcmath/pdo_mysql/mysqli) and config sample for requirements.

## Failures
- https://yourls.org/docs/guide/requirements: 404.
