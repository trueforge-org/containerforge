# zwave-js/zwave-js-ui docker/Dockerfile @ 6aba3da40be776f8ee845de144477098978d3b74

## Source URL(s) + date
- https://raw.githubusercontent.com/zwave-js/zwave-js-ui/6aba3da40be776f8ee845de144477098978d3b74/docker/Dockerfile (fetched 2026-11-27)
- github.com blob URL with same commit: duplicate, not fetched separately.

## ARGs / images
- `# syntax docker/dockerfile:1`.
- `NODE_IMAGE` default `node:24.22.1-alpine3.23` (no digest). `ALPINE_IMAGE` default `alpine:3.23` (no digest).
- `plugins`, `updateDevices`, `zwavejs` (default GitHub master tarball of node-zwave-js; used only if `updateDevices` set).

## Stages
1. `node` = `${NODE_IMAGE}`
2. `alpine` = `${ALPINE_IMAGE}`
3. `base-amd64` from alpine; `base-arm64` from base-amd64; `base-arm` from alpine (apk nodejs, nodejs-dev, npm; checks Alpine Node major equals NODE_IMAGE major).
4. `base` = `base-${TARGETARCH}`.
5. `build-js` = `${NODE_IMAGE}` on `$BUILDPLATFORM`: apk jq build-base linux-headers python3-dev (virtual, then removed); `npm ci`; `npm run build`.
6. `build-native` from base: same build deps; `npm ci --omit=dev`; `npm_config_build_from_source=true npm rebuild @serialport/bindings-cpp`; optional `npm install ${plugins}`.
7. `runtime` from base; copies `/usr/src/app` from build-native.

## Packages
- alpine: openssl, libusb, tzdata, eudev.
- base-amd64: copies Node libs/bin from `node` stage.

## Runtime
- WORKDIR `/usr/src/app`.
- ENV `TAG_NAME=${image}` (image ARG default `zwave-js-ui`), `NODE_ENV=production`.
- EXPOSE 8091. CMD `["node", "server/bin/www"]`.
- No USER (runs as root), no VOLUME, no ENTRYPOINT, no HEALTHCHECK.

## Gotchas
- Native `@serialport/bindings-cpp` built from source in build stage.
- Node 24 is the target runtime; build fails if arm alpine Node major mismatches.
