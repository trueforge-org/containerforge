# schollz/cowyo README

Source: https://raw.githubusercontent.com/schollz/cowyo/main/README.md (fetched 2026-11-26)

## What it is
- Self-contained shared scratchpad / wiki ("pastebin for minimalists"); pages autosave; live multi-user edit
- Optional E2E-encrypted private pages (key in URL fragment), client-side password blocks, page lock, publish, self-destruct, curl interface, versioned page-control API

## Install/run
- `make serve` then http://localhost:8001 ; `make test`
- Docker: none documented; prebuilt binary via GitHub releases page (no run steps)

## Flags
- `-port` (default 8001); no other flags listed here

## Env vars
| Var | Purpose |
| --- | --- |
| DATABASE_URL | switch to PostgreSQL (see .env.example) |
| SITE_URL | public origin (canonical links, paste URLs, robots, sitemap) |
| UMAMI_URL, UMAMI_WEBSITE_ID | analytics |
| GOOGLE_ADSENSE, GOOGLE_ADS_TXT | ads |

## Ports
- 8001 default

## Volumes / paths
- default SQLite, no path given on README

## Build deps
- Go version not stated; npm not stated; make required

## API (brief)
- GET /{page} raw text; POST / new random page; POST /{page} create/replace
- POST /api/v1/pages/{page}/operations (publish, lock, encrypt, self-destruct, ...)
- Rate limit 10 POST/min, burst 5 (HTTP 429 + Retry-After); size limits 16 KiB transformed, 64 KiB per request

## License
- MIT (stated on README)
