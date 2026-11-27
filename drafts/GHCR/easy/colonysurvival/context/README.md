# Sources for colonysurvival (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/colonysurvival/values.yaml | truecharts-colonysurvival.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/colonysurvival/Chart.yaml | truecharts-colonysurvival.md |
| https://store.steampowered.com/app/748090 | steam-appdetails-748090.md (appdetails fetched instead; success:false) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cached copy) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh | ich777-docker-steamcmd-server.md (cached copy) |

Skipped: https://store.steampowered.com/search/?term=Colony+Survival (search page); https://www.steampowered.com (generic homepage). No Docker Hub URL (GHCR image).

Failures:
- Steam appdetails for 748090 returned `success:false`. Store page (app/748090) not fetched as a separate URL. Not retried.

## plan.md corrections
- None made. Chart port 27016/udp, GAME_PARAMS `+server.gameport 27016`, GAME_ID 748090 and SRV_* values match the fetched chart.
