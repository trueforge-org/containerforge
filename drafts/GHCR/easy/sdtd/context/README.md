# sdtd context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sdtd/values.yaml | truecharts-sdtd-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sdtd/Chart.yaml | truecharts-sdtd-chart.md |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile (and raw Dockerfile/README) | ich777-docker-steamcmd-server.md (copied from docs/context cache) |
| https://developer.valvesoftware.com/wiki/SteamCMD | valve-steamcmd.md (copied from cache; source 403, unverified) |
| https://store.steampowered.com/api/appdetails?appids=294420 | steam-appdetails-294420.md (failed) |
| https://store.steampowered.com/app/294420 | steam-store-294420.md (failed) |

Skipped: https://www.steampowered.com (generic storefront homepage, no build facts). No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. No Docker Hub source (GHCR app).

Failures: 3 (steam appdetails returned success false; store page returned the storefront homepage; Valve wiki 403 per cache).

## plan.md corrections
- No edits made.
- Unverified conflicts: TrueCharts values expose ports 26900/tcp, 26900/udp, 26901/udp, 26902/udp, 26903/udp, 27015/udp, 8080/tcp, 8082/tcp. Plan lists 8081/tcp telnet, which does not appear in TrueCharts values (not confirmed wrong).
- Plan line 36 uses `STEAM_APP_IDS`; ich777 wrapper and TrueCharts use `GAME_ID` (ich777-docker-steamcmd-server.md). Plan's own wrapper design, not an upstream fact error.
- Steam app id 294420 consistent with TrueCharts GAME_ID; Steam appdetails could not confirm it.
