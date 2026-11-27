# halflife2deathmatch context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/halflife2deathmatch/values.yaml + Chart.yaml | truecharts-halflife2deathmatch.md |
| Docker Hub | none (image is GHCR: ghcr.io/ich777/steamcmd) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (cache copy from docs/context) |
| (scripts/start.sh, scripts/start-server.sh, README) | ich777-docker-steamcmd-server.md (cache copy) |

Skipped categories: github.com blob/repo HTML duplicates of raw files; store.steampowered.com/app/320 and www.steampowered.com (store pages, budget; the HL2:DM dedicated app ID is not on them); the ich777 `blob/master/Dockerfile` duplicate.

Failures:

- https://developer.valvesoftware.com/wiki/Dedicated_Servers_List and .../Half-Life_2:_Deathmatch_Dedicated_Server: Valve wiki is known 403 (docs/context INDEX). Not retried.

## plan.md corrections

- No edits made.
- Blocker lead (not applied): the TrueCharts chart sets `GAME_ID: "232370"` for this app (truecharts-halflife2deathmatch.md). plan.md section 10 says the dedicated-server app ID is unverified. The chart value is a candidate only; confirm on a Steam page or SteamCMD before using it in plan.md.
- Chart value `GAME_NAME: hl2mp` and `GAME_PARAMS` (`-secure +maxplayers 16 +map dm_overwatch`) are chart-side, and the plan's "launch flags UNVERIFIED" note can use them as the candidate launch line (srcds_run -game hl2mp ...), confirmed upstream start-server.sh uses `srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`.
