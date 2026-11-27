# speedtest-exporter context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/speedtest-exporter/values.yaml | truecharts-speedtest-exporter-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/speedtest-exporter/Chart.yaml | truecharts-speedtest-exporter-chart.md |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/v3.5.4/Dockerfile (raw) | speedtest-exporter-dockerfile-v3.5.4.md |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/v3.5.4/src/requirements.txt (raw) | speedtest-exporter-requirements-v3.5.4.md |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/HEAD/src/requirements.txt | not fetched separately (same file on HEAD; v3.5.4 copy used) |
| https://docs.miguelndecarvalho.pt/projects/speedtest-exporter | speedtest-exporter-docs.md |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter (README) | speedtest-exporter-readme.md (summary only) |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/main/LICENSE (raw) | speedtest-exporter-license.md |
| https://github.com/MiguelNdeCarvalho/speedtest-exporter/releases/tag/v3.5.4 | speedtest-exporter-release-v3.5.4-html.md (asset names not loaded) |
| https://api.github.com/repos/MiguelNdeCarvalho/speedtest-exporter/releases/tag/v3.5.4 (alt. tried) | failed: 403 |

Skipped: https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive tarball and the Ookla CLI tarball (`install.speedtest.net`) are binary downloads, not fetched. No CLA, forgetool, containerforge app, templated or image-ref URLs in the list. Docker Hub is listed as a mirror in the docs (`miguelndecarvalho/speedtest-exporter`), not fetched separately.

Failures: 1 (`releases/tag/v3.5.4` via API returned 403; the HTML page was used instead).

## plan.md corrections
- No edits made.
- Verified, no edit: `python:3.11.0-alpine3.15` Dockerfile base; `adduser`, `USER speedtest` (chart UID 1000); `SPEEDTEST_PORT` default 9798; SPEEDTEST_SERVER; GPL license; Python pins; Ookla download URL pattern and armhf mapping; `/metrics` and `/` endpoints.
- Unverified (not contradicted): plan line 16 `SPEEDTEST_CACHE_FOR` and `SPEEDTEST_TIMEOUT` are not in the docs page (they come from exporter.py per plan, not fetched).
- Note: plan line 8 says the release has no binary assets. The HTML page shows "Assets 2" with names not loaded. Likely the two auto-generated source archives. Not edited.
