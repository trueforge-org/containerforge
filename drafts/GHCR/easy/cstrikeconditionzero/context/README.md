# Context sources: cstrikeconditionzero

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrikeconditionzero/values.yaml | truecharts-cstrikeconditionzero-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrikeconditionzero/Chart.yaml | truecharts-cstrikeconditionzero-chart.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cstrikeczero/scripts/start-server.sh (and blob variant) | ich777-cstrikeczero-start-server.md | fetched |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, scripts/start.sh, start-server.sh (and blob variants) | ich777-docker-steamcmd-server.md | copied from shared cache (master branch) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | copied from shared cache |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ich777/steamcmd`); `https://store.steampowered.com/search/?term=Counter-Strike+Condition+Zero` (search results page, not an app page, not fetched); `https://www.steampowered.com` (marketing homepage); no templated, binary-download or image-ref URLs in the list.

Failures: none.

## plan.md corrections
- None needed. The plan's claims for the `cstrikeczero` branch (`hlds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`, `+app_set_config ${GAME_MOD}`) match the fetched script.
- Not a correction, but a note: the plan's section 7 says to copy `linux32/*` into `/config/.steam/sdk32`. The branch script copies `steamclient.so` from `${SERVER_DIR}`, not `linux32/*`. The plan's design is its own choice, so it was left unchanged. Verify in a run.
