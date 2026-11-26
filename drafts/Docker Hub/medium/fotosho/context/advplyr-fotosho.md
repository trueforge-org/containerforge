# advplyr/fotosho (Dockerfile + package.json + README)

Source URL(s): https://github.com/advplyr/fotosho ; https://github.com/advplyr/fotosho/blob/master/Dockerfile (raw fetched: https://raw.githubusercontent.com/advplyr/fotosho/master/Dockerfile) ; https://raw.githubusercontent.com/advplyr/fotosho/master/package.json ; https://raw.githubusercontent.com/advplyr/fotosho/master/README.md
Date: fetched 2026-11-26

## What it is
- Photo gallery for a home server. Reads photos in place (no copy, no DB), generates thumbnails/previews, albums, slideshow, search/sort, watches photo dir. Backend Express + Socket.io; frontend Vue + Tailwind. Repo archived (read-only) 2024-05-22.

## Build (Dockerfile, master)
- Stage 1 `FROM node:12-alpine` (named build): WORKDIR `/client`; COPY client dir; RUN `npm install`, `npm run generate`.
- Stage 2 (final) `FROM node:12-alpine`: ENV `NODE_ENV=production`, `LOG_LEVEL=INFO`; COPY `/client/dist` from build to `/client/dist`; COPY `index.js`, `package.json`, `server`, `static` from context; RUN `npm install --production`.
- `EXPOSE 80`; `CMD` exec form running node `index.js`.
- No ARG, USER, VOLUME, ENTRYPOINT, HEALTHCHECK, WORKDIR in final stage. Runs as root.

## Runtime deps
- Node 12 (EOL). npm deps (package.json): bcryptjs, chokidar, cookie-parser, cors, exif-reader, express, fast-sort, fs-extra, njodb, node-dir, sharp, socket.io.
- sharp (native, needs prebuilt binary for Node 12).

## Entrypoint/flags
- `node index.js` (CMD). package.json scripts: `dev` and `start` both `node index.js`.

## Env vars
| Var | Value | Source |
| --- | --- | --- |
| NODE_ENV | production | Dockerfile |
| LOG_LEVEL | INFO | Dockerfile |

- No other env vars documented on the README or Docker Hub page.

## Ports
- 80/tcp (EXPOSE). Chart maps 13377 -> 80.

## Volumes/paths
- Not declared in Dockerfile. Chart mounts: `/config`, `/photos` (photo source), `/thumbnails`.

## User/UID
- Root (no USER).

## Healthcheck
- None.

## Version/asset naming
- package.json version `1.0.42`. No GitHub releases (API 404; releases page: none). Tags not confirmed.
- Docker Hub: `advplyr/fotosho:latest` only (amd64, last updated 2021-07-30; digest sha256:49dc426c...).

## Config files
- None documented.

## License
- Not stated in package.json or README ("free and open source", no named license).

## Gotchas
- Node 12 base is EOL; sharp native module builds.
- README: install only via Docker, no step-by-step; Docker Hub page is the only install link.
