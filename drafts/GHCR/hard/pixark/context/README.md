# Context: pixark

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pixark/values.yaml + Chart.yaml | truecharts-pixark.md |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (+ blob variant) | ich777-docker-steamcmd-server.md (cache copy) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cache copy) |
| https://developer.valvesoftware.com/wiki/SteamCMD | valve-steamcmd.md (cache copy: 403, not summarized) |

Skipped: blob variant of the ich777 Dockerfile (duplicate of raw, same cache file); pixark.snail.com (see failures); store.steampowered.com/app (index page, covered by app/824360).

Failures:
- https://store.steampowered.com/app/824360: HTML is generic Steam shell, no game content. Alternative https://store.steampowered.com/api/appdetails?appids=824360 returned `{"824360":{"success":false}}`.
- https://pixark.snail.com: connection failed (port 443). Not retried.
- https://developer.valvesoftware.com/wiki/SteamCMD: 403 (cached result, not retried).

## plan.md corrections
None. No clear factual error proven. Nothing in the fetched TrueCharts values contradicts the plan facts checked.
