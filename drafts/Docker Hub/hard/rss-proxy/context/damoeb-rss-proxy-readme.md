# damoeb/rss-proxy README (master)

Source: https://raw.githubusercontent.com/damoeb/rss-proxy/master/README.md (repo https://github.com/damoeb/rss-proxy), fetched 2026-11-26

## What it is
- Creates ATOM or JSON feeds from static websites or feeds by analysing HTML structure (web-to-feed), plus feed-to-feed filtering.
- Alternative UI to feedless with reduced features; feedless is the successor.
- Advanced features (aggregation, auth, JS prerendering, fulltext, persistence, CLI, GraphQL, plugins) are feedless-only.

## Run (from README)
- `docker pull damoeb/rss-proxy:2.1`
- `docker run -p 8080:8080 -e APP_API_GATEWAY_URL=https://foo.bar -it damoeb/rss-proxy:2.1`
- Open http://localhost:8080.
- Legacy v1: `damoeb/rss-proxy:1`, port 3000.

## Env
| Var | Meaning |
| --- | --- |
| APP_API_GATEWAY_URL | outward-facing URL, used as host in generated feeds |

## Ports
- 8080/tcp (must be exposed; shared Docker network needed for RSS reader).

## Notes
- Changelog: ./changelog.md in repo.
- License: GNU GPLv3 (link to gpl-3.0).
