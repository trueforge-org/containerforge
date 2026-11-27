# Context sources: cstrike1-6

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrike1-6/values.yaml | truecharts-cstrike1-6-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrike1-6/Chart.yaml | truecharts-cstrike1-6-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, scripts/start.sh, start-server.sh (and blob variants) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/90: returned a generic "Welcome to Steam" shell with no game data. The app ID 90 comes from the chart `GAME_ID`.

## plan.md corrections
- None. Chart `GAME_NAME=cstrike` and image tag `cstrike1.6` match the plan.
