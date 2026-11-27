# Context index: dayz

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayz/values.yaml | truecharts-dayz.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayz/Chart.yaml | truecharts-dayz.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and blob variant) | ich777-docker-steamcmd-server.md | shared cache copy |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | shared cache copy |
| https://community.bistudio.com/wiki/DayZ:Hosting_a_Linux_Server | none | failed: 403 (plain and `?action=raw`) |
| https://store.steampowered.com/app/223350 | none | failed: HTML is JS-only, no usable data; appdetails API returns `success:false` for 223350 and 1042420 |
| https://www.bohemia.net/games/dayz | none | failed: returns the site's "404 Objective Not Found" page |

Skipped categories: none in urls.txt beyond the filter. Docker Hub: not applicable, the image is `ghcr.io/ich777/steamcmd` (GHCR).

## Failures
- bistudio wiki: 403, not retried beyond the one alternative.
- Steam store and appdetails: no data for either ID.
- Bohemia: wrong or dead page.

## plan.md corrections
- None. The unverified Steam ID relation (store 223350 vs `GAME_ID` 1042420) stays UNVERIFIED; no fetched source proves or disproves it.
