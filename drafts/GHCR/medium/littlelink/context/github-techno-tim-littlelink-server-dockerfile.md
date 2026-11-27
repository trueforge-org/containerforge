# techno-tim/littlelink-server Dockerfile (pinned commit e7fa7dbb)

Source URL(s) + date:
- https://raw.githubusercontent.com/techno-tim/littlelink-server/e7fa7dbb3178fcd963e6472f25e96a874f496a11/Dockerfile (2026-11-27)

## What it is
Next.js standalone build of LittleLink, multi-stage (Node 26 alpine).

## Build steps / deps
| stage | base | what |
| --- | --- | --- |
| yarn-base | node:26.12.1-alpine@sha256:40cd011b... | `npm install -g yarn@1.22.22` (Node 25+ has no Corepack/Yarn) |
| deps | yarn-base | WORKDIR /usr/src/app; COPY package.json yarn.lock; `yarn install --frozen-lockfile --check-files --network-timeout 600000`; BuildKit cache mount |
| node-build | yarn-base | COPY node_modules from deps + src, public, app, next.config.ts, tsconfig.json, tsconfig.server.json, next-env.d.ts, server.ts; `yarn build`; removes `.next/standalone/node_modules/@img/sharp-libvips-linux-*` and `sharp-linux-*` |
| final | node:26.12.1-alpine (same digest) | WORKDIR /usr/src/app |

## Runtime
- Entrypoint: none (CMD only)
- CMD: `node server.js` (run from /usr/src/app; standalone server)
- USER: `node`
- WORKDIR: /usr/src/app
- COPY into final: `.next/standalone` -> `./`, `.next/static` -> `./.next/static`, `public` -> `./public` (all chown node:node)

## Env vars (Dockerfile ENV)
| var | value |
| --- | --- |
| NODE_ENV | production |
| HOSTNAME | 0.0.0.0 |
| PORT | 3000 |
| NEXT_TELEMETRY_DISABLED | 1 |

## Ports
- EXPOSE 3000

## Healthcheck
- `wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/healthcheck`, interval 30s, timeout 3s, start-period 5s, retries 3

## Gotchas
- Healthcheck uses `wget`; the final stage does not install it explicitly.
- Build-time cache mounts used (`littlelink-yarn-v1-cache-v2`, `littlelink-next-cache-v2`).
