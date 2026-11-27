# Context sources: csgo

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/csgo/values.yaml | truecharts-csgo-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/csgo/Chart.yaml | truecharts-csgo-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, scripts/start.sh, start-server.sh (and blob variants) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://www.steampowered.com` (marketing homepage, no build facts); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/740: returned a generic "Welcome to Steam" shell with no game data. The app ID 740 comes from the chart `GAME_ID`.
- https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers: not fetched. Valve wiki returns 403 (shared cache policy, no retry).

## plan.md corrections
- None. The master-branch Dockerfile and start-server.sh (`srcds_run -game ${GAME_NAME} ...`, `linux32` SDK copy) match the plan.
