# Upstream Koenkk/zigbee2mqtt docker/Dockerfile @ 2.14.3

## Source URL(s) + date
- https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/2.14.3/docker/Dockerfile (fetched 2026-11-27)
- Duplicate in urls.txt, not fetched separately: github.com blob URL of same file.
- api.github.com repo/release endpoints returned 403 (see README).

## What it is
- Upstream multi-stage Node image. Not a ContainerForge base; plan uses python-node.

## Stages
- Global: `ARG TARGETPLATFORM`.
- `FROM alpine:3.24 AS base`, `FROM base AS deps`, `FROM base AS release`.

## base
- ENV `NODE_ENV=production`, WORKDIR `/app`.
- RUN `apk add --no-cache tzdata eudev tini nodejs`.

## deps
- ENV `CI=true`.
- COPY `package.json pnpm-lock.yaml pnpm-workspace.yaml` to `./`.
- RUN (cache mount `/tmp/pnpm-store`): `apk add --no-cache make gcc g++ python3 linux-headers npm jq`; `npm` installs pnpm at version from `packageManager` (via jq); `pnpm config set store-dir /tmp/pnpm-store`; `pnpm install --frozen-lockfile --prod --no-optional`; deletes `prebuilds` of `@serialport/bindings-cpp` under `node_modules/.pnpm/`; `pnpm rebuild @serialport/bindings-cpp`.
- devDependencies skipped; `dist` comes from earlier CI.

## release
- ARG `DATE`, `VERSION`, `COMMIT`.
- OCI labels: title Zigbee2MQTT; licenses GPL-3.0; url/source github.com/Koenkk/zigbee2mqtt; documentation https://www.zigbee2mqtt.io/.
- COPY `--from=deps /app/node_modules ./node_modules`; `dist ./dist`; `package.json LICENSE index.js data/configuration.example.yaml ./`; `docker/docker-entrypoint.sh /usr/local/bin/`.
- RUN `chmod +x /usr/local/bin/docker-entrypoint.sh`; `mkdir /app/data`; `echo "$COMMIT" > dist/.hash`.
- EXPOSE 8080.
- ENTRYPOINT `["docker-entrypoint.sh"]`.
- CMD `["/sbin/tini", "--", "node", "index.js"]`.

## Not present
- No USER, VOLUME, HEALTHCHECK.

## Gotchas
- Upstream runs as root (no USER). Data dir `/app/data` created in image.
- Native `@serialport/bindings-cpp` built at install time; needs gcc/g++/python3/linux-headers in build stage.
