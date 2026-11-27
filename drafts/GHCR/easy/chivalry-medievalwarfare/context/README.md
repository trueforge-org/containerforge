# Sources for chivalry-medievalwarfare (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chivalry-medievalwarfare/values.yaml | truecharts-chivalry-medievalwarfare.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chivalry-medievalwarfare/Chart.yaml | truecharts-chivalry-medievalwarfare.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=chivalrymw | github-ich777-chivalrymw-branch.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=chivalrymw | github-ich777-chivalrymw-branch.md |
| https://store.steampowered.com/api/appdetails?appids=220070 | steam-appdetails-220070.md (success:false) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cached copy) |
| https://github.com/ich777/docker-steamcmd-server | ich777-docker-steamcmd-server.md (cached copy, master) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy, master) |

Skipped:
- https://store.steampowered.com/app/220070 and /search/?term=Chivalry+Medieval+Warfare: store HTML/search, Steam API already returned success:false.
- https://www.steampowered.com: generic homepage, no build data, not fetched.
- No Docker Hub URL (GHCR image).

Failures:
- Steam store appdetails for 220070 returned `success:false` (no data). Not retried.

## plan.md corrections
- None made. Ports 7000/7010/27015 udp, GAME_ID 220070, steam_appid 219640 and the chivalrymw Dockerfile/start-server contents match plan sections 1, 3 and 5. Plan's ports and launch details are consistent with fetched sources.
