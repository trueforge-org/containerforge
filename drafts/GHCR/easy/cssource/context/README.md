# Context sources: cssource

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cssource/values.yaml | truecharts-cssource-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cssource/Chart.yaml | truecharts-cssource-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, scripts/start.sh, start-server.sh (and blob variants) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://www.steampowered.com` (marketing homepage, no build facts); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/232330: returned a generic "Welcome to Steam" shell with no game data. The app ID 232330 comes from the chart `GAME_ID`.
- https://developer.valvesoftware.com/wiki/Source_Dedicated_Server: not fetched. Valve wiki returns 403 (shared cache policy, no retry).

## plan.md corrections
- None. Chart `GAME_NAME=cstrike` matches the plan's `srcds_run -game cstrike`. Master-branch start-server.sh flow matches the plan.
