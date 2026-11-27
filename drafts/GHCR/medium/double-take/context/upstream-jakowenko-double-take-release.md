# jakowenko/double-take upstream release v1.13.2 (HTML alt)

## Source URL(s) + date
- https://github.com/jakowenko/double-take/releases/tag/v1.13.2 (HTML; API returned 403 rate limit)
- https://github.com/jakowenko/double-take (repo root HTML: page shows "MIT license")
- Fetched 2026-11-27

## Release v1.13.2
- Date: 2025-08-18 (from release notes).
- Notes:
  - Bug Fixes: `api: safely serialize values to prevent XSS (e11de9d)`
  - Build: `lock versions (9ba932e)`
- Assets not listed in the extracted HTML (not confirmed as prebuilt binaries).

## Failures
- https://api.github.com/repos/jakowenko/double-take and .../releases/tags/v1.13.2: HTTP 403, API rate limit exceeded for the sandbox IP. Not retried. Alternative (HTML release page) used above.

## Gotchas
- Upstream is source-only per plan; the chart runs the skrashevich fork instead.
