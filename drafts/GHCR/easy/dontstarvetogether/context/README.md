# Context index: dontstarvetogether

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dontstarvetogether/values.yaml | truecharts-dontstarvetogether.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dontstarvetogether/Chart.yaml | truecharts-dontstarvetogether.md | fetched |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md | shared cache copy (blob variant) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md | shared cache copy |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md | ich777-docker-steamcmd-server.md | shared cache copy |
| https://store.steampowered.com/api/appdetails?appids=343050 | none | failed: returns `{"343050":{"success":false}}` |
| https://store.steampowered.com/app/322330 | none | not fetched: the client store page, the server ID is 343050 per chart; appdetails also not usable |
| https://www.klei.com/games/dont-starve-together | klei-dont-starve-together.md | fetched, no build-relevant content |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable, image is GHCR (`ghcr.io/ich777/steamcmd`).

## Failures
- Steam appdetails for 343050: `success:false`. Not retried.

## plan.md corrections
- None edited. Two items for the plan to decide, not edited because the chart is not an upstream source:
  - plan.md line 19 lists 10999/udp, 10998/udp, 27016/udp as draft inferences. The TrueCharts chart uses 10890/udp (main), 8766/udp (authentication), 27016/udp (masterserver) (truecharts-dontstarvetogether.md).
  - plan.md line 10 still says the server app ID is UNVERIFIED. The chart uses `GAME_ID` 343050, which is the only fetched value; the Steam check did not confirm it.
