# Context for fireshare

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/fireshare-app/fireshare | github-fireshare-app-fireshare.md |
| https://github.com/fireshare-app/fireshare/releases/tag/v1.9.3 | github-fireshare-app-fireshare.md |
| https://github.com/fireshare-app/fireshare/blob/HEAD/app/server/requirements.txt | github-fireshare-app-fireshare.md (raw HEAD file) |
| https://github.com/fireshare-app/fireshare/archive/refs/tags/v${VERSION}.tar.gz | not fetched (binary archive); pattern in github-fireshare-app-fireshare.md |
| https://github.com/ShaneIsrael/fireshare | github-shaneisrael-fireshare.md (repo root referenced, Dockerfile fetched) |
| https://github.com/ShaneIsrael/fireshare/blob/6889f4484e3163231ce337ea0aa231b99cbfb5c4/Dockerfile | github-shaneisrael-fireshare.md |
| https://hub.docker.com/r/shaneisrael/fireshare | dockerhub-shaneisrael-fireshare.md |
| https://fireshare.net | fireshare-net.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fireshare | truecharts-fireshare.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| http://127.0.0.1:5000, http://127.0.0.1:8080/ | localhost / loopback |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/python-node (and :3.14.8@sha256 variant) | ghcr image refs, not web pages |

## Fetch failures

- None hard. Notes: the v1.9.3 release page's asset names did not load (count "2" only). The GitHub repo root for ShaneIsrael was not fetched separately (only the pinned Dockerfile).

## plan.md corrections

- None made. Checked: env var names and defaults (match docs/EnvironmentVariables.md), port 80 upstream, GPL-3.0 license (fireshare.net says GPLv3), pinned Python requirements (Flask 3.1.1 matches).
- Unverified (not changed): plan says GitHub "Latest" is v1.9.5; the TrueCharts chart pins `1.9.6` (so the latest release is at least 1.9.6 per the chart). Plan's version line should be re-checked before building.
- Unverified (not changed): plan's startup order (from `entrypoint.sh`, not fetched here), `nginx-extras` need (not checked against `prod.conf`).
