# Lissy93/dashy upstream Dockerfile (master)

## Source URL(s) + date
- https://raw.githubusercontent.com/Lissy93/dashy/master/Dockerfile
- Fetched 2026-11-27 (master branch; the pinned `5a8dc18c1bce` blob URL in urls.txt failed, see README)

## What it is
- Upstream multi-stage build of Dashy (Vue app with Node server), published to ghcr.io/lissy93/dashy.

## Build stages
- `build`: `FROM node:24-alpine`, `WORKDIR /app`, `COPY package.json yarn.lock`, `yarn install --frozen-lockfile --network-timeout 600000`, `COPY . .`, `yarn build`.
- `deps`: `FROM node:24-alpine`, `yarn install --production --frozen-lockfile --network-timeout 600000`, `yarn cache clean`.
- final: `FROM node:24-alpine`.

## Final stage
- ARGs: `VERSION=dev`, `REVISION`, `CREATED`.
- LABELs: title Dashy, description "The self-hosted dashboard", url https://dashy.to, documentation https://dashy.to/docs, source https://github.com/lissy93/dashy, licenses MIT, authors/vendor (upstream author), version/revision/created.
- `ENV NODE_ENV=production IS_DOCKER=true PORT=8080`.
- `WORKDIR /app`.
- `RUN apk upgrade --no-cache && apk add --no-cache tzdata tini iputils-ping`; setcap `cap_net_raw+ep` on `ping`; removes npm and npx from `/usr/local`.
- Copies: `node_modules` (deps stage), `dist`, `public`, `services`, `src/utils/config/ConfigSchema.json`, `server.js`, `package.json` from build; `user-data/conf.yml` (chown node:node).
- `USER 1000:1000`, `EXPOSE 8080`.
- `HEALTHCHECK --interval=5m --timeout=10s --start-period=20s --retries=3 CMD node services/healthcheck.js`.
- `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["node", "server.js"]`.
- No VOLUME.

## Runtime deps
- Node 24 (alpine upstream). Packages: tzdata, tini, iputils-ping (alpine).

## Env vars
| Name | Value |
| --- | --- |
| NODE_ENV | production |
| IS_DOCKER | true |
| PORT | 8080 |

## Ports
- 8080 (EXPOSE and PORT).

## Volumes/paths
- Config in `/app/user-data/conf.yml` (shipped default copied at build). No VOLUME instruction.

## User/UID
- `1000:1000` (upstream). Node image default user is `node`.

## Healthcheck
- `node services/healthcheck.js` every 5m. TrueCharts uses exec `node /app/services/healthcheck`.

## Gotchas
- Upstream capabilities: `setcap cap_net_raw+ep` on ping (needs build-time cap support; the plan does not replicate it unless ping is required).
- Upstream runs `tini` as PID 1. Plan execs node directly.
- Build assumes the source tree (`yarn build`); release tarball contents are not confirmed here.
