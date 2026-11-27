# Context sources: dayofdefeatsource

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayofdefeatsource/values.yaml | truecharts-dayofdefeatsource-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayofdefeatsource/Chart.yaml | truecharts-dayofdefeatsource-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob variant) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://www.steampowered.com` (marketing homepage, no build facts); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/232290: returned a generic "Welcome to Steam" shell with no game data. The app ID 232290 comes from the chart `GAME_ID`.

## plan.md corrections
- None. Chart values (`GAME_ID=232290`, `GAME_NAME=dod`, `GAME_PARAMS`, `GAME_PORT=27015`) match the plan.
