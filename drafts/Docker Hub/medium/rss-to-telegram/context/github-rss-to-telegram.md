# GitHub: BoKKeR/RSS-to-Telegram-Bot (tag 2.0.9, commit 3675d2e)

Source URL(s): raw Dockerfile, package.json, start_bot.sh, LICENSE at 3675d2e9c4d9731cec685a8417f7b724e2921e9a; api.github.com repo, releases/tags/2.0.9, contents/.nvmrc, contents/.env.example (fetched 2026-11-27)

## What it is
- "rss-to-telegram-bot" 2.0.9 (NestJS, TypeScript). Repo description: RSS to Telegram python script (stale text). Default branch master, last pushed 2024-06-17.
- License: LICENSE file = GNU GPL v3. GitHub SPDX = GPL-3.0. package.json has `"license": "MIT"`. The LICENSE file is authoritative in this context: GPL-3.0.

## Release
- Tag `2.0.9`, published 2024-02-15T18:52:54Z, no assets. Body: "Merge branch 'develop'". Tag is plain semver `2.0.9`.

## Dockerfile (raw, commit 3675d2e)
- Stage 1 `FROM mhart/alpine-node:16 AS builder`: WORKDIR /app; COPY . .; mkdir node_modules; `npm ci --omit=dev`; `npm run build`.
- Stage 2 `FROM mhart/alpine-node:16`: WORKDIR /app; mkdir config; COPY lib/, dist/, package.json, node_modules/ from builder; COPY ./prisma ./prisma/; COPY ./start_bot.sh .; `RUN apk add sqlite`.
- `ENTRYPOINT ["./start_bot.sh"]`. No ENV, EXPOSE, VOLUME, USER.

## Build scripts (package.json)
- `build`: `nest build` (prebuild rimraf dist; postbuild copy-files copies src/doc md to dist/src).
- `start:prod`: `node dist/main`.
- Runtime deps include @nestjs/*, @prisma/client ^3.15.2, bull ^4.10.4, telegraf ^4.7.0, rss-parser, winston, winston-loki.
- Node: `.nvmrc` = `v16.14.2` (Node 16, EOL).

## start_bot.sh (raw, 3675d2e)
- `#!/bin/sh`. Paths: legacy `config/rss.db` -> backup `config/backup_python_rss.db`; JS DB `config/rss_bot_database.db`.
- If legacy DB exists: cp to backup, `sqlite3 $LEGACY < prisma/migrations/python_to_js_migration.sql`, mv to JS DB, `./node_modules/.bin/prisma migrate resolve --applied init`, `prisma migrate depoy` (typo in upstream).
- Always: `./node_modules/.bin/prisma migrate deploy`, then `node --max_old_space_size=1024 dist/src/main.js` (no exec).
- Requires `sqlite3` binary (alpine: `apk add sqlite`).

## Env vars (.env.example)
| Name | Example | Notes |
| --- | --- | --- |
| TOKEN | telegram:token | Telegram bot token |
| CHATID | -1234 | target chat id |
| DEBUG | true | |
| REDIS_HOST | 127.0.0.1 | Redis required (Bull queue) |
| REDIS_PORT | 6379 | |
| REDIS_USER | default | |
| REDIS_PASSWORD | secret | |
| REDIS_MUTEX | random-value | |

## Ports
- None (no EXPOSE). Outbound Telegram/RSS only.

## Volumes/paths
- `/app/config` (mkdir in image); DB files above live under `config/` relative to /app.

## Runtime deps
- Redis (Bull). Sqlite3 CLI. Node 16 target (upstream).

## Gotchas
- Upstream image is Alpine/musl; not copy-from compatible with glibc bases.
- `start_bot.sh` does not `exec` node; signals not forwarded from sh unless wrapper adds exec.
- Upstream Node 16 is EOL; untested on newer Node.
