# context: nightscout

Fetched 2026-11-26.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nightscout/values.yaml | truecharts-nightscout.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nightscout/Chart.yaml | truecharts-nightscout.md |
| https://hub.docker.com/v2/repositories/nightscout/cgm-remote-monitor-travis/ | dockerhub-cgm-remote-monitor-travis.md |
| https://hub.docker.com/v2/repositories/nightscout/cgm-remote-monitor-travis/tags?page_size=10 | dockerhub-cgm-remote-monitor-travis.md |
| https://github.com/nightscout/cgm-remote-monitor | github-cgm-remote-monitor.md |
| https://github.com/nightscout/cgm-remote-monitor/blob/master/Dockerfile | github-cgm-remote-monitor.md (same as raw) |
| https://raw.githubusercontent.com/nightscout/cgm-remote-monitor/master/Dockerfile | github-cgm-remote-monitor.md |
| https://raw.githubusercontent.com/nightscout/cgm-remote-monitor/master/README.md | github-cgm-remote-monitor.md |
| https://github.com/nightscout/cgm-remote-monitor/releases/tag/v15.0.9 | github-cgm-remote-monitor.md |
| https://nightscout.github.io | nightscout-github-io.md |

Skipped: none of the categories listed in the batch brief were present. No CLA, forgetool schema, containerforge or templated URLs were in the list.

Failures:
- https://api.github.com/repos/nightscout/cgm-remote-monitor/releases/latest: HTTP 403. Alternative tried: release tag HTML page (200). Release assets not verified.

## plan.md corrections
No edits made.

Unverified conflicts (not edited):
- plan.md line 21/152: `INSECURE_USE_http` is the chart spelling. Upstream README uses `INSECURE_USE_HTTP` (uppercase). Plan says it is UNVERIFIED; the README confirms the uppercase form.
- plan.md line 152: `BG_*` and `ENABLE` are described as UNVERIFIED. Upstream README documents `BG_HIGH`, `BG_LOW`, `BG_TARGET_*`, `ENABLE`, `DISPLAY_UNITS`, `BASE_URL`, `THEME`, `TIME_FORMAT` on master (not v15.0.9).
- plan.md line 8: "GitHub release published 2026-10-21, no release assets" not verified (API 403).
