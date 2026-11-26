# webp server docs (docs.webp.sh)

Source URL(s) + fetch date: https://docs.webp.sh/ · fetched 2026-11-26

## Install options
- Docker (recommended): /deployment/docker/. Binary (advanced): /deployment/binary/. CDN: /deployment/cdn/.
- Reverse proxy in front (Nginx) is shown with `proxy_pass http://127.0.0.1:3333/;`.

## Docker compose (landing page, verbatim structure)
- `version: '3'`, service `webp`, image `webpsh/webp-server-go` (alt `ghcr.io/webp-sh/webp_server_go`), `restart: always`.
- Volumes: `./path/to/pics:/opt/pics`, `./exhaust:/opt/exhaust`, `./metadata:/opt/metadata`.
- Ports: `127.0.0.1:3333:3333`.
- Config: custom `config.json` mounted at `/etc/config.json` (generated per the Configuration docs at /configuration/configuration/; examples at /configuration/examples/).
- Started with `docker-compose up -d`. No `docker run` example on the page.

## Other pages (relative paths, not fetched)
- /reference/query-parameters/, /reference/headers/, /reference/extra-params/.

## Facts stated
- Default port 3333.
- Response headers: `Content-Type: image/webp`, `X-Compression-Rate` (e.g. 0.13).
- Cache: converted images to the exhaust folder; metadata to the metadata folder.
- License: GPLv3 (LICENSE file). SECURITY.md present.

## Not stated on the landing page
- Config keys, WEBP_* env var names, CLI flags, config file location (see the Configuration page, not fetched in full).

## Gotchas
- Binary deployment warns of glibc and dependency-library issues.
