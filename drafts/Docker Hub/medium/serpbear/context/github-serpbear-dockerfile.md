# GitHub: towfiqi/serpbear v3.1.2 (Dockerfile, entrypoint, license, release)

Source URL(s): api contents Dockerfile?ref=v3.1.2 and entrypoint.sh?ref=v3.1.2; api repos/towfiqi/serpbear/license; api releases/tags/v3.1.2 (fetched 2026-11-27)

## Release
- Tag `v3.1.2`, published 2026-10-30T16:38:48Z. No release assets (source only).

## License
- GitHub API SPDX: MIT.

## Upstream Dockerfile (v3.1.2)
- Stage `deps`: `FROM node:22-alpine`; `npm ci` (package-lock).
- Stage `builder`: `FROM node:22-alpine`; copies node_modules; COPY . .; `rm -rf data __tests__ __mocks__`; `npm run build` (Next standalone).
- Stage `runner`: `FROM node:22-alpine`; WORKDIR /app; `ENV NODE_ENV=production`.
  - `addgroup --system --gid 1001 nodejs`; `adduser --system --uid 1001 nextjs`; `mkdir -p /app/data && chown nextjs:nodejs /app/data`.
  - COPY public, .next/standalone, .next/static, @babel/runtime from deps, cron.js, email/, database/, .sequelizerc, entrypoint.sh (all chown nextjs:nodejs).
  - `chmod +x /app/entrypoint.sh`; `rm -f package.json && npm init -y`; `npm install --no-package-lock` of croner@9.0.0, cryptr@6.4.0, dotenv@16.0.3, @googleapis/searchconsole@1.0.5, sequelize-cli@6.6.5, concurrently@7.6.0, @isaacs/ttlcache@1.4.1; cache cleanup.
  - Sanity: `npx concurrently --version`, `npx sequelize-cli --version`, require() of the npm packages.
  - `USER nextjs`; `EXPOSE 3000`; `ENTRYPOINT ["/app/entrypoint.sh"]`; `CMD ["npx", "concurrently", "node server.js", "node cron.js"]`.

## entrypoint.sh (v3.1.2)
- `npx sequelize-cli db:migrate --env production`, then `exec "$@"`.

## Ports
- 3000/tcp.

## Volumes/paths
- `/app/data` (SQLite `database.sqlite`, created in image, owned nextjs).

## User/UID
- nextjs uid/gid 1001 (nodejs group gid 1001).

## Runtime deps
- Node 22 (alpine base upstream), npm packages listed above. No external DB.

## Gotchas
- Upstream uses Alpine (musl); ContainerForge plan builds on glibc base.
- Migrations run on each container start via entrypoint.
