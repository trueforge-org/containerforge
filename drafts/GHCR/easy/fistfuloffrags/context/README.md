# Context index: fistfuloffrags

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fistfuloffrags/values.yaml | truecharts-fistfuloffrags.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fistfuloffrags/Chart.yaml | truecharts-fistfuloffrags.md | fetched |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md | shared cache copy (blob variant) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md | shared cache copy |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md | ich777-docker-steamcmd-server.md | shared cache copy |
| https://store.steampowered.com/api/appdetails?appids=265630 | steam-appdetails-fistfuloffrags.md | fetched |
| https://store.steampowered.com/app/265630 | none | not fetched body: HTTP 200 only; covered by the appdetails file |
| https://www.steampowered.com | none | not fetched: HTTP 301 root redirect, no build content |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable, image is GHCR.

Not in urls.txt but needed: appdetails for the chart's server ID 295230 failed (`success:false`), recorded in steam-appdetails-fistfuloffrags.md.

## Failures
- Steam appdetails for 295230: `success:false`. Not retried.

## plan.md corrections
- None edited.
- Plan omission (not an error, not edited): plan.md never names the chart's `GAME_ID` 295230 (dedicated server candidate). The chart value is the only fetched source for it; the plan's line 10 says the server app ID is UNVERIFIED. Chart ports are 27015/udp and 27015/tcp (rcon), which matches the plan's draft inference but is still not upstream-verified.
