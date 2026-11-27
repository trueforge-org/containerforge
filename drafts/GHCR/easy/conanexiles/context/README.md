# Context sources: conanexiles

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/conanexiles/values.yaml | truecharts-conanexiles-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/conanexiles/Chart.yaml | truecharts-conanexiles-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob/raw variants) | ich777-docker-steamcmd-server.md | copied from shared cache (docs/context) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh, start-server.sh | ich777-docker-steamcmd-server.md | copied from shared cache |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://store.steampowered.com/app/443030: returned a generic "Welcome to Steam" shell with no game data. The app ID 443030 comes from the chart `GAME_ID`.

## plan.md corrections
- None. No clear factual error found in the fetched sources. Launch command remains UNVERIFIED (the conanexiles branch scripts were not in the URL list).
