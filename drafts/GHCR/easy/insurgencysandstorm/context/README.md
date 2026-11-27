# insurgencysandstorm context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/insurgencysandstorm/values.yaml + Chart.yaml | truecharts-insurgencysandstorm.md |
| Docker Hub | none (image is GHCR: ghcr.io/ich777/steamcmd) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (and scripts) | ich777-docker-steamcmd-server.md (cache copy from docs/context) |
| https://store.steampowered.com/api/appdetails?appids=581320 | steam-appdetails-581320.md |

Skipped categories: store.steampowered.com/app/581320 and www.steampowered.com (store pages, budget); github.com blob Dockerfile duplicate; www.focus-entmt.com publisher page (not build input).

Failures:

- https://developer.valvesoftware.com/wiki/Insurgency:_Sandstorm_Dedicated_Server: Valve wiki is known 403 (docs/context INDEX). Not retried.

## plan.md corrections

- No edits made.
- Chart GAME_ID 581330 is the dedicated server candidate; plan.md treats it as unconfirmed. Not verified by any fetched source here (appdetails for 581320 is the client app).
