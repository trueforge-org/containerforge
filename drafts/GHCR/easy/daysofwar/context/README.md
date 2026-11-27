# Context sources: daysofwar

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/daysofwar/values.yaml | truecharts-daysofwar-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/daysofwar/Chart.yaml | truecharts-daysofwar-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob variant) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://store.steampowered.com/search/?term=Days+of+War` (search results, not an app page, not fetched); `https://www.steampowered.com` (marketing homepage); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/541790: returned a generic "Welcome to Steam" shell with no game data. The app ID 541790 comes from the chart `GAME_ID`.

## plan.md corrections
- None found in this pass. Chart ports (`GAME_PORT=7777`, `QUERY_PORT=27015`) and `GAME_PARAMS=dow_cathedral` are as in the chart. The chart sets no `GAME_NAME`, which the README notes for the plan author.
