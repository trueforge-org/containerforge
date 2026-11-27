# github gnmyt/myspeed Dockerfiles

Source URL(s): https://raw.githubusercontent.com/gnmyt/MySpeed/7290a97522e5fdeca9e541bc3b6048a88ae20f9c/Dockerfile (pinned, fetched 2026-11-27); https://raw.githubusercontent.com/gnmyt/MySpeed/development/Dockerfile (fetched 2026-11-27)

## Pinned Dockerfile (7290a975, matches 1.0.9 era)
- build stage: `FROM node:18-alpine`; apk add g++ make cmake python3; WORKDIR /myspeed
- copies client, server, package.json; `yarn install`; `cd client && yarn install --force`; `npm run build`; `mv /myspeed/client/build /myspeed`
- runtime: `FROM node:18-alpine`; apk add --no-cache tzdata
- ENV NODE_ENV=production, TZ=Etc/UTC
- WORKDIR /myspeed; copies build/, server/, node_modules/, package.json from build stage
- `VOLUME ["/myspeed/data"]`; `EXPOSE 5216`; `CMD ["node", "server"]`
- runs as root (no USER)

## Development branch Dockerfile
- stages: `oven/bun:1` client-build (bun install, bun run build) ; server-build (bun install, bun run generate-migrations, bun run generate-integrations)
- runtime: `oven/bun:1`; apt tzdata ca-certificates openssl
- ENV TZ=Etc/UTC
- copies server, package.json, node_modules from server-build; client build -> /myspeed/build
- `VOLUME ["/myspeed/data"]`; `EXPOSE 5216`; `CMD ["bun", "run", "server/index.js"]`

## Ports
- 5216

## Volumes
- /myspeed/data

## Gotchas
- Pinned stable uses node:18; development uses bun:1 (different runtime, not the same as Docker Hub 1.0.9)
- No HEALTHCHECK in either Dockerfile
