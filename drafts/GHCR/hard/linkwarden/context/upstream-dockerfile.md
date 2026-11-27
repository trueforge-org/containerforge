# linkwarden/linkwarden Dockerfile v2.17.0 (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/linkwarden/linkwarden/v2.17.0/Dockerfile · fetched 2026-11-27 (head and tail fetched)

## Stages
1. monolith-builder: `docker.io/rust:1.96-bookworm`, `cargo install --locked monolith@2.11.7` (ARG MONOLITH_VERSION)
2. app-builder: `node:22.23.4-bookworm-slim`, yarn workspaces (apps/web, apps/worker, packages/*), `yarn prisma:generate`, `yarn web:build`, then prune to production deps. PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1.
3. main-app: `node:22.23.4-bookworm-slim`, WORKDIR /data

## Runtime
- ENV NODE_ENV=production, PRISMA_HIDE_UPDATE_MESSAGE=1, PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
- monolith copied to /usr/local/bin/monolith
- apt: curl ca-certificates openssl procps
- Copies node_modules, package.json, yarn.lock, .yarnrc.yml, apps/web, apps/worker, packages to /data
- `corepack enable && corepack install`
- `playwright install --with-deps chromium-headless-shell`
- `mkdir -p apps/web/.next/cache && chmod 777` (Next.js image cache, works for non-root)

## Entrypoint / command
- EXPOSE 3000
- HEALTHCHECK curl --fail http://127.0.0.1:3000/ (interval 30s, timeout 5s, start 10s, retries 3)
- CMD: `prisma migrate deploy --schema=/data/packages/prisma/schema.prisma` then `concurrently -k -n web,worker` running `next start` in apps/web and `tsx worker.ts` in apps/worker
- No USER directive in fetched content (head and tail; middle not fetched)

## Gotchas
- Requires Chromium headless shell at runtime (Playwright).
- Prisma migrations run on every start.
- GitHub releases/latest API for linkwarden rate limited (403), not retried.
