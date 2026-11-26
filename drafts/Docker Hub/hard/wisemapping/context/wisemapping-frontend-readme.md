# wisemapping-frontend README

## Source URL(s) + date
- https://raw.githubusercontent.com/wisemapping/wisemapping-frontend/master/README.md (fetched 2026-11-26)
- Dockerfile clones branch `develop` (default `FRONTEND_BRANCH`); master README used for docs.

## What it is
- React/TypeScript UI monorepo (Yarn workspaces). Packages: `web2d` (SVG abstraction), `mindplot` (vanilla ES6 map rendering), `editor` (React wrapper), `webapp` (React app).

## Install/build steps + deps
- Node per `package.json` engines (README does not state a version; Dockerfile uses `node:24-alpine`), yarn (`npm i -g yarn` per README; Dockerfile uses corepack `yarn@4.13.0`).
- `nvm use`; `yarn install`.
- Production build: `yarn build` (root). Docker build uses `APP_CONFIG_TYPE=file:prod yarn build --concurrency 1`.
- Dev: `export APP_CONFIG_TYPE="file:dev"`; in `packages/webapp`: `yarn start`.
- Tests: `yarn test`, `yarn test:integration`, `yarn test:unit`, visual snapshots via `yarn workspace @wisemapping/editor test:visual` (baselines are macOS-only).

## Runtime deps
- Static build output only (webapp `dist/`). No runtime Node needed.

## Entrypoint/flags
- Not applicable (static assets).

## Env vars
| Var | Use |
| --- | --- |
| APP_CONFIG_TYPE | `file:dev` (local), `file:prod` (build config) |

## Ports
- Dev server port 3000 (README examples).

## Config files
- `packages/webapp/config.prod.json` (`"url"` API base; upstream Dockerfile patches it with sed).

## License
- "WiseMapping Open License, Version 1.0" (same as backend README).

## Gotchas
- Integration tests use dynamic port allocation (`TESTING_PORT_ALLOCATION.md`).
- Visual snapshot baselines only match on macOS.
