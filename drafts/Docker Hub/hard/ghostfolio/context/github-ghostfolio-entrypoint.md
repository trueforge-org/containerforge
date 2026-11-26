# ghostfolio docker/entrypoint.sh

Source URL: https://raw.githubusercontent.com/ghostfolio/ghostfolio/45d692301c1e9c0dca5bcc77cb06a9e408af019c/docker/entrypoint.sh
Date fetched: 2026-11-26
Summary only (fetch returned a paraphrase, not verbatim).

## What it is
Startup script copied to `/ghostfolio/entrypoint.sh`, run as CMD.

## Behaviour (in order)
- Shell: `sh`, starts with `set -ex` (echo commands, exit on error).
- 1. `npx prisma migrate deploy` (database migrations)
- 2. `npx prisma db seed` (seeding)
- 3. `exec node main` (replaces shell; Node is PID 1 and receives signals)

## Env vars read
- None read directly by the script. Prisma may read its own config (database URL) from the environment.

## Gotchas
- Migrations and seed run on every container start, before the server. A database must be reachable at start.
- `exec node main` resolves relative to WORKDIR `/ghostfolio/apps/api`.
