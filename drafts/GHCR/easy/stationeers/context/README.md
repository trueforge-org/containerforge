# stationeers context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/stationeers/values.yaml | truecharts-stationeers-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/stationeers/Chart.yaml | truecharts-stationeers-chart.md |
| https://developer.valvesoftware.com/wiki/SteamCMD | valve-steamcmd.md (copied from cache; 403, unverified) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (copied from cache, master branch; stationeers branch not fetched) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (copied from cache) |
| https://stationeers.net and https://stationeers.net/ | stationeers-site.md (failed: empty content) |

Skipped: https://www.steampowered.com (generic Steam homepage; the storefront homepage returned no app facts in the sdtd batch). No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. No Docker Hub source (GHCR app).

Failures: 2 (stationeers.net returned empty content for both URL variants; Valve wiki 403 per cache, not retried).

## plan.md corrections
- No edits made.
- Verified, no edit: app id 600760 (TrueCharts GAME_ID); ports 27015/udp and 27500/udp (TrueCharts services; plan line 15 states the same); ich777 Dockerfile base and USER/UID defaults (cache, master branch).
- Unverified conflict: plan line 15 says the draft's `27016/udp` is not confirmed. TrueCharts uses 27015 and 27500 only; no 27016. Not edited.
- Unverified conflict: plan line 14 `GAME_PARAMS=-difficulty easy -loadlatest Mars Mars` (ich777 stationeers branch, not fetched) vs TrueCharts `AutoSave true SaveInterval 300`. Chart override; not an upstream error.
- Still open per plan: server binary name, launch flags, settings.xml location (stationeers branch of ich777 not fetched; no source available here).
