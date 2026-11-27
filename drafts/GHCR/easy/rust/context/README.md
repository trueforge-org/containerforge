# Context index: rust

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rust/values.yaml | truecharts-rust.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rust/Chart.yaml | truecharts-rust.md |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (shared cache) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (shared cache) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md | ich777-docker-steamcmd-server.md (shared cache) |
| https://developer.valvesoftware.com/wiki/SteamCMD | valve-steamcmd.md (shared cache; 403, not summarized) |
| https://rust.facepunch.com | rust-facepunch-site.md |
| https://store.steampowered.com/api/appdetails?appids=258550 | steam-appdetails-258550.md |
| https://www.steampowered.com | steampowered-home.md |

Skipped: no Docker Hub source (image is ghcr.io/ich777/steamcmd). No CLA, forgetool, containerforge or templated URLs in the list.

Failures: 1 (Valve wiki, HTTP 403 in shared cache; not retried). Steam appdetails returned success:false (no data, not a fetch error).

Unverified risk: chart does not set GAME_NAME (image default `template`); the ich777 base start script launches `srcds_run -game ${GAME_NAME}`. Whether the rust tag uses a different launch path was not verified from the URLs in the list.

## plan.md corrections
- None (plan.md not read; URL list was non-empty)
