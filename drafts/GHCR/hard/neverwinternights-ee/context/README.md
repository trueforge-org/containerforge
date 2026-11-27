# Context: neverwinternights-ee

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/neverwinternights-ee/values.yaml + Chart.yaml | truecharts-neverwinternights-ee.md |
| https://raw.githubusercontent.com/ich777/docker-nwnee/master/Dockerfile (+ blob variant) | ich777-docker-nwnee-dockerfile.md |
| https://raw.githubusercontent.com/ich777/docker-nwnee/master/scripts/start.sh | ich777-docker-nwnee-start-sh.md |
| https://raw.githubusercontent.com/ich777/docker-nwnee/master/scripts/start-server.sh (follow-up, not in urls.txt) | ich777-docker-nwnee-start-server-sh.md |
| https://www.beamdog.com/games/neverwinter-nights-enhanced (and https://www.beamdog.com) | beamdog-nwn-ee.md |

Skipped: https://github.com/ich777/docker-nwnee/blob/master/Dockerfile (duplicate of raw); https://store.steampowered.com/app/704450 (store marketing page, not fetched).
Failures:
- https://api.github.com/repos/ich777/docker-nwnee: HTTP 403 (not retried; repo metadata not needed).
- https://store.steampowered.com/app/704450: not fetched (marketing; budget).
- https://www.beamdog.com: not fetched separately (covered by game page).

## plan.md corrections
- No edit made. Confirmation (not a correction): chart service.main is protocol udp port 5121 (plan.md line 14 says UNVERIFIED; the chart values support it).
- Not confirmed here: plan.md line 15 license null (came from API, not refetched; API 403 here).
