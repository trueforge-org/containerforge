# shlink-web-client nginx.conf (v4.9.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.1/config/docker/nginx.conf (from blob URL in urls.txt)
- Fetched 2026-11-27

## Server
- `listen 8080 default_server;` (IPv6 form not reported)
- no server_name
- charset utf-8; index index.html
- root `/usr/share/nginx/html`

## Locations
- `location = /servers.json { try_files /servers.json /conf.d/servers.json; }`
- static-extension location (`~*` regex): `try_files $uri $uri/ =404;`
- catch-all `location /`: `try_files $uri $uri/ /index.html$is_args$args;` (SPA fallback)

## Caching
- manifest/html/xml/json: `expires -1` (no cache)
- images/fonts-like extensions (jpg, png, svg, gz, mp4, etc.): `expires 1M`, `Cache-Control "public"`
- css/js: `expires 1y`, `Cache-Control "public"`

## Gotchas
- No gzip directive, no envsubst placeholders, no /etc/nginx paths.
- Regex extension blocks are unanchored; first match wins, so .json/.css are caught by the expiry blocks before try_files.
