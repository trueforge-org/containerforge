# Upstream Dockerfile: jordan-dalby/ByteStash (commit eb4ecdfc)

**Source URL(s):** https://raw.githubusercontent.com/jordan-dalby/ByteStash/eb4ecdfc30f2e7d1424137fa7fe3a9eed663218b/Dockerfile (blob URL in urls.txt is the same file; fetched 2026-11-27)

## Client stage (`client-build`)
- `FROM --platform=$BUILDPLATFORM node:22.23.4-alpine AS client-build`.
- `WORKDIR /app/client`; `COPY client/package.json`; `RUN npm install --package-lock-only`; `RUN npm ci`; `COPY client/`.
- `ARG APP_VERSION=dev`; `ENV VITE_APP_VERSION=$APP_VERSION`; `RUN npm run build`.
- Comment: builds natively (arch-independent output; avoids QEMU OOM on arm/v7).

## Production stage
- `FROM node:22.23.4-alpine AS production`, `WORKDIR /app`.
- `COPY server/package.json ./`
- `RUN apk add --no-cache --virtual .build-deps python3 make g++ gcc && npm install --omit=dev && apk del .build-deps && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx`
- `COPY server/src ./src`; `COPY server/docs ./docs`
- `COPY --from=client-build /app/client/build /client/build`
- `RUN mkdir -p ./data/snippets`
- `EXPOSE 5000`
- `CMD ["node", "src/app.js"]`. No ENTRYPOINT, no USER.

## Env vars (Dockerfile)
| Var | Value |
| --- | --- |
| APP_VERSION | build arg (default dev) -> VITE_APP_VERSION |

## Ports
- 5000 (EXPOSE)

## Volumes/paths
- `/app/data/snippets` (created at build; relative to /app). `/client/build` (static client copied to root, not /app/client).
- No VOLUME directive.

## User/UID
- None set (runs as root by image default).

## Arch
- Client built on BUILDPLATFORM; server native modules compiled in production stage (build-deps installed then removed).

## Gotchas
- Client is copied to `/client/build` while the server path in the Dockerfile is `/app`; server code resolves its client path from its own location (not verified from source in this fetch).
- Only `server/package.json` is installed; `package-lock` not copied to production stage.
