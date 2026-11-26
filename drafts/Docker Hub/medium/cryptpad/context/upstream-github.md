# cryptpad/cryptpad (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/docker-entrypoint.sh
- https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/LICENSE (AGPL v3)
- https://api.github.com/repos/cryptpad/cryptpad/releases/latest

## What it is
Self-hosted end-to-end encrypted collaboration suite (Node.js web app). Upstream Docker image is a 2-stage build on `node:lts-slim`.

## Install/build steps (upstream Dockerfile at cbeb1b76)
- Build stage `FROM node:lts-slim AS build`; `WORKDIR /cryptpad`; `COPY . /cryptpad`
- `sed -i "s@installMethod: 'unspecified'@installMethod: 'docker'@" /cryptpad/config/config.example.js`
- `mv /cryptpad/config /cryptpad/config.local`
- `RUN npm install --production && npm run install:components`
- Final stage `FROM node:lts-slim`, `ENV DEBIAN_FRONTEND=noninteractive`
- `groupadd cryptpad -g 4001 && useradd cryptpad -u 4001 -g 4001 -d /cryptpad`
- apt: `bash curl ca-certificates git rdfind unzip` (`--no-install-recommends`, then apt clean/rm lists)
- `COPY --from=build --chown=cryptpad /cryptpad /cryptpad`; `USER cryptpad`
- `RUN mkdir blob block customize data datastore`

## Runtime deps
- Node (node:lts-slim). apt tools only for optional OnlyOffice install (`rdfind`, `git`, `unzip`).

## Entrypoint/flags
- `ENTRYPOINT ["/bin/bash", "/cryptpad/docker-entrypoint.sh"]`
- `CMD ["npm", "start"]`
- docker-entrypoint.sh (bash, `set -e`):
  1. If `/cryptpad/config/config.js` missing: `cp config.local/config.example.js config/config.js` (prints warning).
  2. If `/cryptpad/config/infra.js` missing: `cp config.local/infra.example.js config/infra.js` (prints warning).
  3. `cd /cryptpad`
  4. If `CPAD_INSTALL_ONLYOFFICE == yes` or `CPAD_INSTALL_OFFICE == yes`: `./install-office.sh --accept-license --trust-repository`
  5. `npm run build` (runs on every start)
  6. `exec "$@"`
- Header comment lists `CPAD_MAIN_DOMAIN`, `CPAD_SANDBOX_DOMAIN`, `CPAD_CONF` but the script does not use them.

## Env vars
| Var | Default | Used by |
| --- | --- | --- |
| DEBIAN_FRONTEND | noninteractive | Dockerfile build only |
| CPAD_INSTALL_ONLYOFFICE | unset | entrypoint (`yes` triggers install-office.sh) |
| CPAD_INSTALL_OFFICE | unset | entrypoint (`yes` triggers install-office.sh) |

Config is not templated from env: operator edits `config.js` and `infra.js`.

## Ports
- 3000 (`EXPOSE 3000`, web). Sandbox port not in the Dockerfile.

## Volumes/paths
- Upstream `VOLUME`: `/cryptpad/blob`, `/cryptpad/block`, `/cryptpad/customize`, `/cryptpad/data`, `/cryptpad/datastore`, `/cryptpad/config`.
- Install home: `/cryptpad` (also user home).

## User/UID
- `cryptpad` UID 4001, GID 4001, home `/cryptpad`. `USER cryptpad`.

## Config files
- `/cryptpad/config/config.js` and `/cryptpad/config/infra.js` (seeded from `config.local/*.example.js` if missing).

## Healthcheck
- `HEALTHCHECK --interval=1m CMD curl -f http://localhost:3000/ || exit 1`

## Version/asset naming
- Latest release (API): tag `2026.10.1`, name "Autumn fix release (2026.10.1)", published 2026-11-10T11:41:49Z, no assets (source tarball only).
- Source tarball pattern: `https://github.com/cryptpad/cryptpad/archive/refs/tags/${VERSION}.tar.gz` (per plan; not fetched).
- Commit cbeb1b76 is the commit the plan's Dockerfile was read from; its version is not stated in the fetched files.

## Arch
- Not stated in fetched files (node:lts-slim is multi-arch).

## Gotchas
- Upstream `npm run build` runs in the entrypoint on every start, not at image build.
- `sed` target string must match `config.example.js` exactly (`installMethod: 'unspecified'`).
- Entrypoint refers to `config.example.js` / `infra.example.js` without a directory, and copies from `config.local/`.
- Upstream image is built with `install-office.sh` only when env vars set.
- `set -e` in entrypoint: any build failure stops startup.

## Licence
- AGPL-3.0 (LICENSE raw file fetched, "GNU AFFERO GENERAL PUBLIC LICENSE Version 3").
