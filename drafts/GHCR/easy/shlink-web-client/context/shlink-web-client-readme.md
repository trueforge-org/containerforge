# shlink-web-client README (develop branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/shlinkio/shlink-web-client/develop/README.md
- Fetched 2026-11-27

## What it is
- ReactJS PWA front end for Shlink (URL shortener); runs fully client-side.
- Servers (name, url, apiKey) stored in browser local storage; can export/import.

## Run / configure
- Docker Hub image `shlinkio/shlink-web-client` (README); container port 8080; document root `/usr/share/nginx/html`.
- Pre-config options:
  - mount `servers.json` at `/usr/share/nginx/html/servers.json` (since 2.1.0)
  - mount dir with `servers.json` at `/usr/share/nginx/html/conf.d/` (since 3.2.0)
  - env vars for one server (since 3.2.0): `SHLINK_SERVER_URL`, `SHLINK_SERVER_API_KEY`, `SHLINK_SERVER_NAME` (default "Shlink")
- servers.json: JSON array of `{name, url, apiKey}`.
- Security note: file is browser-readable, so API keys can leak. Only for trusted self-hosted use.

## Build
- Node 10.15+ for classic build: `npm install`, `node --run build`, output `build/`.
- Docker build: `docker build . -t shlink-web-client`.
- Subpath: set `homepage` in package.json.

## Gotchas
- README names Docker Hub; TrueCharts and the plan use GHCR `ghcr.io/shlinkio/shlink-web-client`.
- SPA needs fallback to `index.html`.
