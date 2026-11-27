# slskd context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slskd/values.yaml | truecharts-slskd-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slskd/Chart.yaml | truecharts-slskd-chart.md |
| https://github.com/slskd/slskd/blob/e472ecd/Dockerfile (raw) | slskd-dockerfile-e472ecd.md |
| https://github.com/slskd/slskd/blob/master/docs/config.md (raw) | slskd-docs-config.md |
| https://github.com/slskd/slskd/blob/master/LICENSE (raw) | slskd-license.md |
| https://github.com/slskd/slskd (raw README) | slskd-readme.md |
| https://github.com/ansible-slskd/slskd | failed: HTML 404, API 403 (ansible role, not build source) |

Skipped: none by category. No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. Release zip (`slskd-0.26.2-linux-*.zip`) is a binary download, not fetched. No Docker Hub source (GHCR app).

Failures: 1 (ansible-slskd/slskd: HTML 404, one API alternative 403).

## plan.md corrections
- No edits made.
- Verified, no edit: version 0.26.2 (chart appVersion and image tag); AGPL-3.0-only (LICENSE); ports 5030/5031/50300 and HEALTHCHECK on `/health`; `ENV SLSKD_APP_DIR=/app`, user 1000, tini/gosu entrypoint (Dockerfile).
- Unverified conflict: plan line 20 and 48 use `SLSKD_APP_DIR`. Upstream Dockerfile sets `SLSKD_APP_DIR=/app`, but docs/config.md names the variable `APP_DIR`. Both may be honored; not edited.
- Unverified: web login env names (chart uses `SLSKD_USERNAME`/`SLSKD_PASSWORD` for web UI auth). Plan does not mention them. Soulseek account env names (`SLSKD_SLSK_USERNAME`/`SLSKD_SLSK_PASSWORD`, plan line 18) are not confirmed by docs/config.md either (the page only says `SLSKD_` prefix).
- Image namespace: README says `slskd/slskd`, TrueCharts and plan use `ghcr.io/slskd/slskd`. No change needed.
