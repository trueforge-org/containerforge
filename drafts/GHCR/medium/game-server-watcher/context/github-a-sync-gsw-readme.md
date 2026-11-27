# Upstream README + .env.example + package.json: a-sync/game-server-watcher

## Source URL(s) + date
- https://raw.githubusercontent.com/a-sync/game-server-watcher/master/README.md (fetched 2026-11-27)
- https://raw.githubusercontent.com/a-sync/game-server-watcher/master/.env.example (fetched 2026-11-27)
- https://raw.githubusercontent.com/a-sync/game-server-watcher/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/package.json (fetched 2026-11-27)
- Repo root https://github.com/a-sync/game-server-watcher covered by the README.

## What it is
- Simple discord/telegram/slack bot that monitors game servers (gamedig + Steam API) and relays status. Has a web "GSW Control Panel" (`SECRET`-protected) to manage servers and bots. Project status: mature.
- License: AGPL (LICENSE.md).

## Install/build steps
- `npm i` then `npm run build` (tsc). Run with `node ./dist/server.js` (`npm start`).
- Host install: copy `package.json`, `public/` and `dist/`, then `npm i --only=prod`.
- Docker: README says pre-built images are at `ghcr.io/a-sync/game-server-watcher`. Compose example exists (not fetched).

## Runtime deps
- Node.js. README: `>=16.20.0`. package.json engines: `node >=16.20.0`.
- Optional deps include `bufferutil`.

## Entrypoint/flags
- `npm start` = `node ./dist/server.js`. `npm run dev` uses nodemon (dev only).

## Env vars (.env.example)
| Name | Default | Description |
| --- | --- | --- |
| DBG | 0 | debug mode |
| REFRESH_TIME_MINUTES | 2 | game server refresh interval (min) |
| DATA_PATH | ./data/ | writable data storage folder |
| SECRET | secret | admin secret (README: set a unique one) |
| HOST | 0.0.0.0 | web service host |
| PORT | 8080 | web service port |
| DISCORD_BOT_TOKEN | (empty) | |
| TELEGRAM_BOT_TOKEN | (empty) | |
| SLACK_BOT_TOKEN | (empty) | |
| SLACK_APP_TOKEN | (empty) | |
| STEAM_WEB_API_KEY | (empty) | |

## Ports
- Web UI on 8080 by default (README and `.env.example`).

## Volumes/paths
- `DATA_PATH` must be writable. README: "Make sure the service can write to the data storage path."

## Config files
- `.env` (dotenv) optional; `.env.example` lists values. Configuration page in web UI updates the config file and restarts the service.

## Healthcheck
- None documented.

## Gotchas
- README: flush data (game server history, discord/telegram/slack bot message) is manual. Bots have no cleanup of leftover messages.
- Tokens: Steam key, Discord/Telegram/Slack bot tokens (wiki links; not fetched).
- Hosting targets in README (fly.io, Azure, Cloud Run, DO) are not relevant to the container build.
