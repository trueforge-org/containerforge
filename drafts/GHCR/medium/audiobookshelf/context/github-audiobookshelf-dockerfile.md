# Upstream Dockerfile: advplyr/audiobookshelf

**Source URL(s):** https://raw.githubusercontent.com/advplyr/audiobookshelf/1430c9fc642d586ff91c8d4cbed20aab2c47e473/Dockerfile (blob URL in urls.txt is the same file; fetched 2026-11-27)

## Stages (all `node:24-alpine`, musl)
1. **build-client**: `WORKDIR /client`, `COPY /client`, `npm ci && npm cache clean --force`, `npm run generate`.
2. **compile-server** (`--platform=$BUILDPLATFORM`): `COPY index.js package* tsconfig.server.json`, `COPY /server /server/server`, `npm ci --include=dev --ignore-scripts && npm run build:server`.
3. **build-server**: `ENV NODE_ENV=production`; apk `curl make python3 g++ unzip`; copies `index.js package*`, `/server`, `dist-server`.
   - Per TARGETPLATFORM: `linux/amd64` -> `https://github.com/mikiher/nunicode-sqlite/releases/download/v1.2/libnusqlite3-linux-musl-x64.zip`; `linux/arm64` -> `...-linux-musl-arm64.zip`; other = fail.
   - unzip to `$NUSQLITE3_DIR` (`/usr/local/lib/nusqlite3`); `npm ci --omit=dev`.
4. **final** (`node:24-alpine`): apk `tzdata ffmpeg tini`; `WORKDIR /app`.
   - COPY `/client/dist` -> `/app/client/dist`; `/server` -> `/app`; libnusqlite3.so -> `$NUSQLITE3_PATH`.
   - `EXPOSE 80`
   - `ENTRYPOINT ["tini", "--"]`, `CMD ["node", "dist-server/index.js"]`

## Env vars (final stage)
| Var | Value |
| --- | --- |
| PORT | 80 |
| NODE_ENV | production |
| CONFIG_PATH | /config |
| METADATA_PATH | /metadata |
| SOURCE | docker |
| NUSQLITE3_DIR | /usr/local/lib/nusqlite3 |
| NUSQLITE3_PATH | /usr/local/lib/nusqlite3/libnusqlite3.so |

## Build args
- `NUSQLITE3_DIR`, `NUSQLITE3_PATH` (ARG defaults), `TARGETPLATFORM`.

## Ports
- 80 (EXPOSE, PORT=80)

## Volumes/paths
- No VOLUME directive. Paths used: `/config`, `/metadata`, `/app`.

## User/UID
- None set (runs as root).

## Arch
- amd64 and arm64 only (TARGETPLATFORM case). Other platforms error out.

## Gotchas
- nunicode-sqlite library is a **musl** binary downloaded at build time from GitHub releases (not glibc compatible).
- Compile stage runs on build platform to avoid QEMU SIGILL on arm64 (comment in Dockerfile).
