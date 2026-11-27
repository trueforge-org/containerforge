# Context sources: craftopia

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/craftopia/values.yaml | truecharts-craftopia-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/craftopia/Chart.yaml | truecharts-craftopia-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob/raw variants) | ich777-docker-steamcmd-server.md | copied from shared cache (docs/context) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh, start-server.sh | ich777-docker-steamcmd-server.md | copied from shared cache |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); store search page `https://store.steampowered.com/search/?term=Craftopia` (search results, not an app page, low value); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/1670340: returned a generic "Welcome to Steam" shell with no game data. The app ID 1670340 comes from the chart `GAME_ID`.

## plan.md corrections
- None. No clear factual error found in the fetched sources. Launch command remains UNVERIFIED.
