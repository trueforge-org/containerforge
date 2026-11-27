# GitHub: zadam/trilium Dockerfile (commit 51939b16)

Source URL(s): https://raw.githubusercontent.com/zadam/trilium/51939b161c4754f1a5326e2f019ac6a217bea993/Dockerfile (fetched 2026-11-27)

## Build
- Header: "Don't try to build this Dockerfile directly, run it through bin/build-docker.sh".
- FROM `node:18.18.2-alpine`; WORKDIR /usr/src/app; COPY . .; COPY server-package.json package.json.
- RUN (build deps added then removed: autoconf automake g++ gcc libtool make nasm libpng-dev python3): `npm install`; `npm run webpack`; `npm prune --omit=dev`; copy `src/public/app/share.js` and `doc_notes` into `src/public/app-dist/`; rm `src/public/app`.
- RUN apk add `su-exec shadow`; `adduser -s /bin/false node` (errors ignored).
- EXPOSE 8080. CMD `["./start-docker.sh"]` (script not in fetched content).
- HEALTHCHECK --start-period=10s `exec su-exec node node docker_healthcheck.js`.

## Runtime deps
- Node 18.18.2 (alpine), su-exec, shadow.

## User/UID
- `node` user (adduser default UID, not stated here).

## Ports
- 8080/tcp

## Gotchas
- Chart image is zadam/trilium 0.63.7; urls.txt also lists TriliumNext/Trilium (see github-triliumnext-config.md).
