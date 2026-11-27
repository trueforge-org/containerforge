# GitHub: diamkil/socials (pinned commit 2b7a17b5)

Source URL(s): https://raw.githubusercontent.com/diamkil/socials/2b7a17b519896cc18b775536d7f9016921df133a/Dockerfile , .../package.json , .../src/app.ts (fetched 2026-11-27)

## What it is
- Node.js/TypeScript site; package `socials` 2.0.0; license ISC; author diamkil.

## Dockerfile (2-stage, node:lts-alpine)
- build stage: WORKDIR /build; COPY . .; `yarn install`; `yarn build`; `yarn install --production`
- runtime stage: WORKDIR /app; copies `public`, `dist`, `node_modules`, `views` from build; `COPY people/ ./people/`
- EXPOSE 7574
- CMD `node dist/app.js` (no USER directive; runs as root)

## Build/runtime deps
- yarn; `build` = `tsc && sass --no-source-map styles/:public/css --style compressed`
- Runtime deps: ejs ^3.1.6, express ^4.17.1

## Entrypoint/flags
- CMD only, no entrypoint script, no flags.

## Env vars
| var | default | use |
| --- | --- | --- |
| PORT | 7574 | express listen port (app.ts) |
| DEFID | default | default person id (app.ts) |

## Ports
- 7574/tcp

## Volumes/paths
- Content read from `/app/people` in the image (copied at build time from repo `people/`); TrueCharts mounts persistence at `/app/people`.
- Static files served from `public` (cwd-relative), views from `views`.

## User/UID
- Not set in Dockerfile (root).

## Gotchas
- Entry uses `express.static('public')` and `res.render('../views/someone.ejs')`; paths are cwd-relative, so run from `/app`.
