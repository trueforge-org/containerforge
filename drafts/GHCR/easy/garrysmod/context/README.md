# Context index: garrysmod

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/garrysmod/values.yaml | truecharts-garrysmod.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/garrysmod/Chart.yaml | truecharts-garrysmod.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob variant) | ich777-docker-steamcmd-server.md | shared cache copy |
| https://www.steampowered.com | none | not fetched: root redirect, no build content |
| https://store.steampowered.com/app/4020 | none | not fetched: HTTP 302, store page; appdetails below failed |
| https://store.steampowered.com/api/appdetails?appids=4020 | none | failed: `{"success":false}` |
| https://developer.valvesoftware.com/wiki/Garry%27s_Mod_Dedicated_Server | none | not fetched: Valve wiki returns 403 (shared cache note), not retried |
| https://www.steampowered.com (listed as `https://www.steampowered.com`) | none | duplicate of the entry above |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable, image is GHCR.

## Failures
- Steam appdetails for 4020: `success:false`.
- Valve wiki: 403 per shared cache (valve-dedicated-server-guide / valve wiki note). Not retried.

## plan.md corrections
- None edited. The chart's `GAME_ID` 4020 matches plan line 42. The server app ID is still not confirmed by any fetched source (plan line 11 and the blocker on line 142 stay as written).
