# homarr-labs/homarr: Dockerfile + scripts/entrypoint.sh (tag v2.13.1), docs

Source URL(s): https://raw.githubusercontent.com/homarr-labs/homarr/v2.13.1/Dockerfile (fetched 2026-11-27; blob/v2.13.1 variant same), https://raw.githubusercontent.com/homarr-labs/homarr/v2.13.1/scripts/entrypoint.sh (follow-up, fetched). https://homarr.dev/docs (follow-up, nav text only; Env vars page exists but not fetched).

## Build (Dockerfile v2.13.1, syntax docker/dockerfile:1.28)
- bun-tool: oven/bun:1.4.4-debian. redis-tool: redis:8.8.0-trixie (redis-server, redis-cli copied). base: node:24.22.2-trixie-slim.
- builder (node base): apt ca-certificates python3 make g++ (native fallbacks); copies bun; `bun install --frozen-lockfile` (npm_config_nodedir=/usr/local); then `bun run turbo run build --filter=@homarr/nextjs... --filter=@homarr/cli`.
- runner: debian:trixie-slim. apt: libstdc++6 libatomic1 libzstd1 zlib1g ca-certificates nginx bash gettext-base util-linux openssl wget. mkdir /appdata, nginx dirs, /etc/nginx/ssl/certs.
- Copies: node binary, redis-server/redis-cli to /usr/local/bin; /app/apps/cli/cli.cjs; better_sqlite3.node to /app/build/; /app/db/migrations; Next standalone output to /app; scripts/run.sh; scripts/trusted-proxies.mjs; entrypoint.sh (chmod 755); redis.conf to /app/redis.conf; nginx.conf to /etc/nginx/templates/nginx.conf.
- /usr/bin/homarr CLI wrapper: `cd /app/apps/cli && exec node ./cli.cjs "$@"`.
- VOLUME /appdata.

## Env (image defaults)
| Name | Value |
| --- | --- |
| DB_URL | /appdata/db/db.sqlite |
| DB_DIALECT | sqlite |
| DB_DRIVER | better-sqlite3 |
| AUTH_PROVIDERS | credentials |
| REDIS_IS_EXTERNAL | false |
| NODE_ENV | production |
| PUID / PGID (entrypoint.sh) | default 0 / 0 |
| *_FILE suffix | entrypoint loads env var value from file path (Docker secrets) |

## Entrypoint / CMD
- ENTRYPOINT ["/app/entrypoint.sh"]; CMD ["sh", "run.sh"].
- entrypoint.sh: if PUID or PGID != 0: chown /appdata (db, redis, trusted-certificates subdirs), /app/apps/nextjs/.next/cache, /var/cache/nginx, /var/log/nginx, /var/lib/nginx, /run/nginx, /etc/nginx; then exec `setpriv --reuid=$PUID --regid=$PGID --clear-groups "$@"`; else exec "$@" as root.
- Note: app code under /app is intentionally not chowned.

## Ports / healthcheck
- EXPOSE 7575.
- HEALTHCHECK interval 30s, timeout 5s, start-period 60s, retries 3: node fetch HEAD http://127.0.0.1:7575/api/health/live.

## Volumes/paths
- /appdata (sqlite db, redis dumps, trusted certs), /app/db/migrations, /etc/nginx/templates/nginx.conf (rendered by run.sh; not read).

## Runtime deps
- nginx, redis-server (bundled), node 24, better-sqlite3 native module, envsubst (gettext-base), setpriv (util-linux), openssl (AUTH_SECRET generation).

## Docs
- homarr.dev/docs: sections for install, env vars (deployment settings and defaults), SSO, scheduled tasks. Env var table not fetched.

## Gotchas
- Dockerfile does not set USER; default runs as root unless PUID/PGID set.
- Build is multi-stage with BuildKit secrets for TURBO_* (optional).
- run.sh and nginx.conf not fetched.
