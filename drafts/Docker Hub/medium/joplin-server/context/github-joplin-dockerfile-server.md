# Upstream Dockerfile.server (laurent22/joplin @ 6fcc076) + LICENSE

## Source URL(s) + date
- https://raw.githubusercontent.com/laurent22/joplin/6fcc076/Dockerfile.server (2026-11-26)
- https://raw.githubusercontent.com/laurent22/joplin/dev/LICENSE (2026-11-26)
- Duplicate not fetched: https://github.com/laurent22/joplin/blob/6fcc076/Dockerfile.server (same content as raw).

## Build stage (`FROM node:24.22.1 AS builder`)
- apt: `python3 tini libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev` then `rm -rf /var/lib/apt/lists/*`.
- `corepack enable`. WORKDIR `/build`.
- COPY `.yarn/releases`, `.yarn/patches`, `package.json`, `.yarnrc.yml`, `yarn.lock`, `gulpfile.js`, `tsconfig.json`, `packages/{turndown,turndown-plugin-gfm,fork-htmlparser2,fork-sax,fork-uslug,htmlpack,renderer,tools,utils,lib,server}`.
- `sed -i '/onenote-converter/d' ./packages/lib/package.json`.
- License rewrite: `sed -i 's/"license": "AGPL-3.0-or-later"/"license": "UNLICENSED"/' ./package.json ./packages/*/package.json`.
- `BUILD_SEQUENCIAL=1 yarn config set cacheFolder /build/.yarn/cache && yarn install --inline-builds`.
- Disable postinstall: `sed -i 's/"postinstall": ".*"/"postinstall": ""/' ./package.json ./packages/*/package.json`.
- `yarn workspaces focus --production --all`.
- Cache mounts: `/build/.yarn/cache`, `/build/.yarn/berry/cache`.

## Final stage (`FROM node:24.22.1-slim`)
- `ARG user=joplin`; `useradd --create-home --shell /bin/bash joplin`.
- `npm i -g pm2@5.4.3`; `mkdir -p /opt/pm2`; chown to joplin; `ENV PM2_HOME=/opt/pm2`.
- `USER joplin`.
- COPY from builder: `/build/node_modules` -> `/home/joplin/node_modules`; `/build/packages` -> `/home/joplin/packages`; `/usr/bin/tini` -> `/usr/local/bin/tini`.
- `pm2 install https://registry.npmjs.org/pm2-logrotate/-/pm2-logrotate-3.0.0.tgz`; `pm2 set pm2-logrotate:max_size 100MB`; `retain 5`; `compress true`.
- `ARG LICENSE_REQUIRED="0"`; `ENV LICENSE_REQUIRED=${LICENSE_REQUIRED}`.
- `ENV NODE_ENV=production`, `ENV RUNNING_IN_DOCKER=1`.
- `EXPOSE ${APP_PORT}`.
- `WORKDIR /home/joplin/packages/server`.
- `ENTRYPOINT ["tini", "--"]`; `CMD ["yarn", "start-prod"]`.
- `ARG IMAGE_NAME="Joplin Server"`; `ENV APP_NAME=${IMAGE_NAME}`.
- OCI labels from build args: BUILD_DATE, REVISION, VERSION, SOURCE. `org.opencontainers.image.url=https://joplinapp.org/`.

## Runtime deps
- Node 24 (`node:24.22.1-slim`), pm2 5.4.3, tini, pm2-logrotate 3.0.0. Native libs for node-canvas (cairo, pango, jpeg, gif, rsvg) are installed only in the builder stage; no runtime apt install in the final stage.

## Entrypoint/flags
- `tini -- yarn start-prod`.

## Env vars (set by Dockerfile)
| Name | Value |
| --- | --- |
| NODE_ENV | production |
| RUNNING_IN_DOCKER | 1 |
| LICENSE_REQUIRED | build arg, default "0" |
| APP_NAME | build arg IMAGE_NAME, default "Joplin Server" |
| PM2_HOME | /opt/pm2 |
| APP_PORT | used by EXPOSE; value not set in Dockerfile |

## Ports
- `EXPOSE ${APP_PORT}` (no default in Dockerfile).

## User/UID
- `joplin` (created by useradd, no explicit UID).

## License
- LICENSE (dev root): text reads "All code in this repository is licensed under the AGPL-3.0-or-later License unless a directory contains a LICENSE or LICENSE.md file".
- Build rewrites `packages/*` and root package.json `license` to `UNLICENSED`.

## Gotchas
- Upstream comment: `yarn install` ignores NODE_ENV=production and installs dev deps; they are removed by `workspaces focus --production`.
- Tail of file (verified): nothing beyond OCI labels.
