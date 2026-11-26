# Flowko/website-shot (upstream app and Dockerfile)

## Source URL(s) + date
- https://raw.githubusercontent.com/Flowko/website-shot/HEAD/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/Flowko/website-shot/72076a845f18d38522b696fd080dac3eda3cd781/Dockerfile (fetched 2026-11-26, pinned commit from urls.txt)

## What it is
- Open-source web page screenshot app, Node.js + Nuxt (JS/Vue). Full-page capture.
- README: "under active development, most features experimental".
- Cannot screenshot pages that require login.

## Install/build steps + deps (upstream Dockerfile)
- Base: `node:16.18.1-alpine`
- `WORKDIR /usr/src/website-shot`
- `apk add --no-cache git chromium wqy-zenhei --repository http://nl.alpinelinux.org/alpine/edge/testing`
- `COPY package*.json` then `RUN yarn install`
- `COPY . /usr/src/website-shot/` then `RUN yarn generate` then `RUN yarn build`

## Runtime deps
- Node 16 (upstream), Chromium (apk), wqy-zenhei CJK font.

## Entrypoint/flags
- `CMD [ "yarn", "start" ]`
- README dev/prod: `yarn dev` (hot reload), `yarn build` + `yarn start`, `yarn generate` (static).

## Env vars (upstream Dockerfile defaults)
| Var | Default | Notes |
| --- | --- | --- |
| NUXT_HOST | 0.0.0.0 | |
| NUXT_PORT | 3000 | |
| PASSWORD_PROTECT | 0 | `1` enables password |
| PASSWORD | null | README: default `admin` when protect enabled |
| RUNNING_DOCKER | 1 | |
| USER_AGENT | Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 | |
| BLOCK_ADS | 1 | |

## Ports
- `EXPOSE 3000`

## Volumes/paths
- None declared upstream. Workdir `/usr/src/website-shot`.

## User/UID
- Not set (runs as root in upstream image).

## Config files
- `package.json`, `package*.json`; `.dockerignore` noted in Dockerfile comment.

## Healthcheck
- None upstream.

## Version/asset naming
- README badge uses GitHub release tag for `Flowko/website-shot`. No asset binaries; source build only.

## Arch
- Not stated.

## Gotchas
- Dockerfile uses an `edge/testing` Alpine repo for chromium and wqy-zenhei.
- Docker usage in README: `docker run -p 3000:3000 -e PASSWORD_PROTECT=1 -e PASSWORD=yourpassword flowko1/website-shot`.
- Password field is shown on the homepage when protection is on.
