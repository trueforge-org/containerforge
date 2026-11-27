# Upstream: libredb/libredb-studio Dockerfile + docker-entrypoint.sh (commit 58adba536f0283fecb7b761053cb2401dd7187eb)

Source URL(s) + date: https://raw.githubusercontent.com/libredb/libredb-studio/58adba536f0283fecb7b761053cb2401dd7187eb/{Dockerfile,docker-entrypoint.sh} (fetched 2026-11-27)
Failed: https://api.github.com/repos/libredb/libredb-studio (403) and .../releases/latest (403). Not retried.

## Stages
1. `deps`: `FROM oven/bun:1.4.4`. apt installs python3 make g++. `COPY package.json bun.lock`, `bun install --frozen-lockfile`.
2. `builder`: `FROM node:26.13.0-trixie-slim`. Copies deps node_modules, `COPY . .`. ENV `NEXT_TELEMETRY_DISABLED=1`, `DOCKER_BUILD=true`. `ARG BASE_PATH=""` (bakes Next.js prefix). Build-time placeholder ARGs: `JWT_SECRET_BUILD`, `ADMIN_PASSWORD_BUILD`, `USER_PASSWORD_BUILD` (ENV set from them).
   - Run: `node scripts/copy-monaco.mjs && npx next build`.
   - Prune: `bash scripts/lib/prune-standalone-payload.sh .next/standalone`, removes `public/screenshots`, musl duckdb/sharp/better-sqlite3 prebuilds, db2-node non-glibc addons; asserts payload loads.
3. `runner`: `FROM node:26.13.0-trixie-slim`, `WORKDIR /app`.

## Runner layout
- ENV: NODE_ENV=production, NEXT_TELEMETRY_DISABLED=1, NODE_OPTIONS=`--max-old-space-size=384`, WORKFLOW_LOCAL_DATA_DIR=/app/data/workflow, PORT=3000, HOSTNAME="" (empty sentinel).
- `public/` copied. `mkdir -p .next data`. `.next/standalone` -> `./`, `.next/static` -> `./.next/static`.
- Copies explicit node_modules: better-sqlite3, @libredb/libredb, @duckdb (scope), detect-libc, oracledb (whole dir), `THIRD_PARTY_NOTICES.txt`, `seed-assets/`.
- User: `addgroup --system --gid 1001 nodejs`, `adduser --system --uid 1001 nextjs`. `chown -R nextjs:nodejs /app`, `chgrp 0 /app/data /app/.next`, `chmod g=u /app/data`, `chmod g=u,+t /app/.next`. No `USER` line (root start needed for volume chown).
- `apt-get install gosu`.
- `COPY docker-entrypoint.sh /usr/local/bin/`, chmod +x.
- `COPY docker/bind-address.mjs /usr/local/lib/libredb-studio/bind-address.mjs`; `docker/discover.mjs`; `docker/discover-kubernetes.mjs` (no --chown, root-owned).
- `EXPOSE 3000/tcp`. `ENTRYPOINT ["docker-entrypoint.sh"]`. `CMD ["node", "server.js"]`.

## docker-entrypoint.sh
- Resolves bind address via `LIBREDB_BIND_RESOLVER` (default `/usr/local/lib/libredb-studio/bind-address.mjs`) run as `gosu nextjs:nodejs node` when root. Sets `HOSTNAME` to result; falls back to `0.0.0.0` with warning if resolver fails.
- If uid 0: `DATA_DIR=$(dirname ${STORAGE_SQLITE_PATH:-/app/data/libredb-storage.db})`, `mkdir -p`, `chown -R nextjs:nodejs`, `exec gosu nextjs:nodejs "$@"`. Else `exec "$@"`.

## Env vars (Dockerfile)
| Var | Value |
| --- | --- |
| NODE_ENV | production |
| NEXT_TELEMETRY_DISABLED | 1 |
| NODE_OPTIONS | --max-old-space-size=384 |
| WORKFLOW_LOCAL_DATA_DIR | /app/data/workflow |
| PORT | 3000 |
| HOSTNAME | "" (resolved by entrypoint) |

## Ports
- 3000/tcp.

## Volumes/paths
- `/app/data` (SQLite, workflow data, auth-bootstrap.json); `.next` group-writable cache.

## User/UID
- Container starts as root; entrypoint drops to `nextjs` (uid 1001, gid 1001). `--user` / podSecurityContext non-root start: exec directly.

## Healthcheck
- None in Dockerfile.

## Gotchas
- Builder build args for placeholder JWT/admin secrets exist only at build time.
- Native modules: glibc only in final image; musl prebuilds pruned.
- Oracle driver kept Thin-only (no Instant Client).
