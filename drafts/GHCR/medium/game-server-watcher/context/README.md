# Context: game-server-watcher

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/game-server-watcher/values.yaml | truecharts-game-server-watcher.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/game-server-watcher/Chart.yaml | truecharts-game-server-watcher.md |
| https://raw.githubusercontent.com/a-sync/game-server-watcher/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile | github-a-sync-gsw-dockerfile.md |
| https://github.com/a-sync/game-server-watcher/blob/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile | same as above (not fetched separately) |
| https://github.com/a-sync/game-server-watcher | github-a-sync-gsw-readme.md (via raw README, master) |
| https://raw.githubusercontent.com/a-sync/game-server-watcher/master/README.md | github-a-sync-gsw-readme.md |
| .env.example and package.json (raw, same repo) | github-a-sync-gsw-readme.md |

Skipped: no Docker Hub page (GHCR image only, no Docker Hub entry in urls.txt); wiki links (token guides), docker-compose.yml, eggs, deploy buttons, gamedig/steam/discord reference docs, Azure/Cloud deploy links (not build inputs).

Failures: none.

## plan.md corrections
- None applied. Unverified conflict: plan draft port 3000 vs upstream default `PORT=8080` (`.env.example`, Dockerfile `EXPOSE 8080`) and chart `PORT=10690`. Left for the port decision in plan section 10.
- Upstream env var names confirmed (DBG, REFRESH_TIME_MINUTES, DATA_PATH, SECRET, HOST, PORT, DISCORD_BOT_TOKEN, TELEGRAM_BOT_TOKEN, SLACK_BOT_TOKEN, SLACK_APP_TOKEN, STEAM_WEB_API_KEY). Plan marked these UNVERIFIED; the README now resolves that.
