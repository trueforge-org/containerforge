# Upstream Dockerfile: a-sync/game-server-watcher

## Source URL(s) + date
- https://raw.githubusercontent.com/a-sync/game-server-watcher/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile (fetched 2026-11-27)
- Blob URL https://github.com/a-sync/game-server-watcher/blob/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile is the same file (not fetched separately).

## What it is
- Node.js bot/web service (TypeScript, `tsc` build) that monitors game servers and posts to Discord/Telegram/Slack.

## Build stages
| Stage | Base | Steps |
| --- | --- | --- |
| base | `node:20` | `WORKDIR /app`, `ENV NODE_ENV=production`, `LABEL fly_launch_runtime="Node.js"` |
| builder | base | `COPY package.json package-lock.json`, `npm ci --include=dev`, `COPY . .`, `npm run build`, `rm -rf node_modules` |
| final | base | `COPY --from=builder /app /app`, `npm ci --omit=dev`, `EXPOSE 8080`, `CMD ["npm","run","start"]` |

- `npm run start` = `node ./dist/server.js`. `npm run build` = `tsc`.
- Node engine per package.json: `>=16.20.0` (Dockerfile uses node:20).

## Entrypoint/flags
- No ENTRYPOINT. CMD `npm run start`.

## Env vars (from upstream .env.example, README)
| Name | Default | Note |
| --- | --- | --- |
| DBG | 0 | debug mode |
| REFRESH_TIME_MINUTES | 2 | refresh interval |
| DATA_PATH | ./data/ | writable data folder (lowdb JSON) |
| SECRET | secret | admin secret for control panel |
| HOST | 0.0.0.0 | web host |
| PORT | 8080 | web port |
| DISCORD_BOT_TOKEN | empty | |
| TELEGRAM_BOT_TOKEN | empty | |
| SLACK_BOT_TOKEN | empty | |
| SLACK_APP_TOKEN | empty | |
| STEAM_WEB_API_KEY | empty | |

## Ports
- `EXPOSE 8080`. Control panel served at `http://localhost:8080` by default.

## Volumes/paths
- No VOLUME. Data path set by `DATA_PATH` (README: copy `public/` and `dist/` for host installs).

## User/UID
- No USER: runs as root.

## Healthcheck
- None.

## Version/asset naming
- Container images: `ghcr.io/a-sync/game-server-watcher` (README). Tags are `v`-prefixed (chart uses `v3.1.26`).

## Gotchas
- Build needs `package-lock.json` (`npm ci`). `npm ci --include=dev` in builder, then `rm -rf node_modules` before copy.
- Final stage copies the whole `/app` from builder and re-runs `npm ci --omit=dev`.
- Node 20 base, not alpine.
