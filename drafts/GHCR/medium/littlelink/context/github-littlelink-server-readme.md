# timothystewart6/littlelink-server README + package.json (main branch)

Source URL(s) + date:
- https://raw.githubusercontent.com/timothystewart6/littlelink-server/main/README.md (2026-11-27, truncated at ~4 KB)
- https://raw.githubusercontent.com/timothystewart6/littlelink-server/main/package.json (2026-11-27)

## What it is
- Self-hosted link page; Next.js + React + TypeScript; config from env vars read at request time (restart container, no rebuild).
- Inspired by sethcottle/littlelink. License: MIT (LICENSE.md).

## Dev/build requirements
- Node.js 24+, Yarn Classic 1.22.x.
- Scripts: `build` = `next build && tsc -p tsconfig.server.json`; `start` = `NODE_ENV=production node dist-server/server.js`.
- package.json `name` littlelink-server, version 1.0.0, private, main app.js.
- Runtime deps: next 16.4.6, react/react-dom 19.3.1, express ^4.21.2, compression, morgan.

## Env vars (documented in README)
| var | purpose |
| --- | --- |
| OG_URL | enables /sitemap.xml and robots sitemap link |
| META_INDEX_STATUS | `all` allows indexing; `noindex` disables sitemap (404) |
| ROBOTS_ADDITIONAL_RULES | appended robots rules; `\n` converted to newlines |
| ROBOTS_TXT | replaces generated robots.txt entirely |

## Healthcheck
- `/healthcheck` endpoint (used by upstream Dockerfile).

## Gotchas
- Only the first ~4 KB of the README was fetched; other env vars are not listed here.
- Upstream README/package.json are from timothystewart6 fork; the container image in the chart is from techno-tim.
