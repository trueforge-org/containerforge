# Upstream Dockerfile: actualbudget/actual sync-server (alpine)

**Source URL(s):** https://raw.githubusercontent.com/actualbudget/actual/1766241e3f4b3c578e424c4fa15f1eb83c0da17d/packages/sync-server/docker/alpine.Dockerfile (blob variant of the same path in urls.txt; fetched 2026-11-27). Tag v26.11.0 per plan.

## Stages
- **builder**: `FROM alpine:3.23`. Installs `nodejs python3 openssl build-base`.
  - Copies `.yarn`, `yarn.lock`, `package.json`, `.yarnrc.yml`, `packages`.
  - Symlinks vendored yarn (`/app/.yarn/releases/yarn-*.cjs`) to `/usr/local/bin/yarn` (no Corepack on Alpine).
  - armv7l: `yarn config set taskPoolConcurrency 2`, `networkConcurrency 5`.
  - `yarn workspaces focus @actual-app/sync-server --production`.
  - If `better-sqlite3` binding is missing (non x64/arm64), `node-gyp rebuild --release`.
  - Dereferences workspace symlinks (`cp -RL`), strips `src e2e __tests__ __mocks__ tests test build-stats` under `@actual-app`.
- **prod**: `FROM alpine:3.23`. `apk add nodejs tini`.
  - ARG `USERNAME=actual`, `USER_UID=1001`, `USER_GID=$USER_UID`; `addgroup -S ... -g`, `adduser -S ... -u`.
  - `mkdir /data && chown -R actual:actual /data`.
  - `WORKDIR /app`, `ENV NODE_ENV=production`.
  - Copies `node_modules`, `packages/sync-server/package.json`, `packages/sync-server/build` into `/app`.
  - `mkdir -p src && ln -s ../scripts src/scripts`.
  - `ENTRYPOINT ["/sbin/tini","-g","--"]`, `EXPOSE 5006`, `CMD ["node","app.js"]`.

## Runtime deps
- Alpine packages: nodejs, tini. Node version not pinned in Dockerfile (alpine repo).

## Entrypoint/flags
- `tini -g -- node app.js`

## Env vars
| Var | Value |
| --- | --- |
| NODE_ENV | production |

## Ports
- 5006 (EXPOSE)

## Volumes/paths
- `/data` (created, owned by actual)
- `/app` (WORKDIR)

## User/UID
- `actual`, UID/GID 1001 (ARG-overridable), `adduser -S` system user.

## Arch
- builder compiles better-sqlite3 when not x64/arm64 (armv6/armv7 path).

## Gotchas
- Built on musl (alpine), not glibc.
- `CMD` is `node app.js` at `/app` (flattened build layout).
