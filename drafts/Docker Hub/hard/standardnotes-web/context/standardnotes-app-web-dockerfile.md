# standardnotes/app packages/web: Dockerfile + package.json

Source URL(s): https://github.com/standardnotes/app/blob/main/packages/web/Dockerfile (raw, fetched 2026-11-26); https://raw.githubusercontent.com/standardnotes/app/main/packages/web/package.json (follow-up).

## Dockerfile (full content)
- `FROM nginx:alpine` (unpinned)
- `COPY ./dist /usr/share/nginx/html`
- That is all. Build context must already contain `dist/` (built output). No USER line, no EXPOSE, no ENV, no nginx.conf in this file.

## Build of dist (package.json, @standardnotes/web v3.203.3)
- `build`: `yarn clean && yarn copy:components && webpack --config web.webpack.prod.js && yarn tsc`
- `start`: `webpack-dev-server --config web.webpack.dev.js` (dev only); `start-secure`: `yarn start --https`
- Monorepo: packages/web is inside standardnotes/app (yarn workspaces).

## Gotchas
- Image is a static nginx serving SPA files; port 80 from nginx base image.
- nginx default config (nginx:alpine) used; packages/web/nginx.conf (if any) not in this Dockerfile and its fetch returned 404 (not counted as a source).
