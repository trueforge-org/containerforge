# hurtworld context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hurtworld/values.yaml + Chart.yaml | truecharts-hurtworld.md |
| Docker Hub | none (image is GHCR: ghcr.io/ich777/steamcmd) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and scripts/start.sh, start-server.sh) | ich777-docker-steamcmd-server.md (cache copy from docs/context) |
| https://store.steampowered.com/api/appdetails?appids=393420 | steam-appdetails-393420.md |

Skipped categories: store.steampowered.com/app/393420 and /app/... HTML pages and www.steampowered.com (store pages; budget); github.com blob Dockerfile duplicate.
Not fetched: appdetails for 405100 (not in urls.txt; plan.md already records it does not resolve on the store API).

Failures: none.

## plan.md corrections

- No edits made.
- Confirmed by appdetails: app 393420 is the Hurtworld store (client) entry (type game, name Hurtworld). Plan's line about the draft's 393420 being the client app is consistent.
- Dedicated server app ID 405100 (chart GAME_ID) remains UNVERIFIED in plan.md; not confirmed by any fetched source here.
