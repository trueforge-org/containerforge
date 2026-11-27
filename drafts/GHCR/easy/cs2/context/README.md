# Context sources: cs2

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cs2/values.yaml | truecharts-cs2-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cs2/Chart.yaml | truecharts-cs2-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/Dockerfile (and github blob/tree variants) | ich777-cs2-dockerfile.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/scripts/start.sh | ich777-cs2-scripts.md | fetched; start-server.sh fetched as follow-up, merged here |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, scripts/start.sh, start-server.sh | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |
| https://store.steampowered.com/app/730 | steam-store-730.md | fetched; title only |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://github.com/ich777/docker-steamcmd-server/tree/cs2` (HTML tree, raw variant used); `https://www.counter-strike.net` (marketing homepage, no build facts, not saved); no templated, binary-download or image-ref URLs in the list.

Failures:
- https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers: not fetched. Valve wiki returns 403 (shared cache policy, no retry).

## plan.md corrections
- None. Launch path, LD_LIBRARY_PATH, sdk64 copy, and Dockerfile ENV/apt list match the cs2 branch. Image digest `sha256:UNVERIFIED` in the plan remains unverified.
