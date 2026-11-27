# sissbruecker/linkding - docker/default.Dockerfile

Source URL(s) + date: https://raw.githubusercontent.com/sissbruecker/linkding/24b5ad6/docker/default.Dockerfile (fetched 2026-11-27); same content as https://github.com/sissbruecker/linkding/blob/24b5ad6/docker/default.Dockerfile

## Stages (default image = `linkding`)
| Stage | Base | Work |
| --- | --- | --- |
| node-build | `--platform=$BUILDPLATFORM node:22-alpine` | COPY package.json package-lock.json; `npm ci`; COPY bookmarks/frontend, bookmarks/styles; `npm run build` |
| build-deps | `python:3.13.7-slim-trixie` | apt: build-essential pkg-config libpq-dev libicu-dev libsqlite3-dev libffi-dev libpcre2-dev wget unzip; ADD uv install.sh `https://astral.sh/uv/0.8.13/install.sh`; `uv sync --no-dev --group postgres` |
| compile-icu | from build-deps | SQLite amalgamation 3430000 (year 2023) headers; compile ICU ext `gcc -fPIC -shared icu.c ... -o libicu.so` |
| linkding (final) | `python:3.13.7-slim-trixie` | apt runtime: media-types libpq-dev libicu-dev libssl3t64 libpcre2-8-0 curl |
| ublock-build | `node:22-alpine` | fetch uBlock via scripts/setup-ublock.sh (apk curl jq unzip) |
| linkding-plus | from linkding | Chromium + Node 22 + single-file-cli@2.0.75 + simple-cdp@1.8.6; uBOLite; `LD_ENABLE_SNAPSHOTS=True` (not needed for this app) |

## Final stage (linkding) details
- WORKDIR `/etc/linkding`
- COPY venv from build-deps `/etc/linkding/.venv`; COPY `bookmarks/static` from node-build; COPY `libicu.so`; COPY `. .`
- `ENV VIRTUAL_ENV=/etc/linkding/.venv`, `PATH=/etc/linkding/.venv/bin:$PATH`
- `RUN mkdir data && python manage.py collectstatic`
- `ENV UWSGI_MAX_FD=4096`
- `EXPOSE 9090`
- `RUN chmod g+w . && chmod +x ./bootstrap.sh` (arbitrary-user / root-group support)
- HEALTHCHECK: `curl -f http://localhost:${LD_SERVER_PORT:-9090}/${LD_CONTEXT_PATH}health`
- `CMD ["./bootstrap.sh"]` (no ENTRYPOINT, no USER)
- LABEL org.opencontainers.image.source=https://github.com/sissbruecker/linkding

## Gotchas
- Build needs `npm ci` with node 22 and uv 0.8.13 installer (downloaded by ADD).
- ICU ext is compiled from sqlite.org src raw URL pinned by sha256 query (`?name=91c0...`).
- Upstream has no USER; chmod g+w on app dir for arbitrary UID.
