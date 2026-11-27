# deconz context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/deconz/values.yaml | truecharts-deconz-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/deconz/Chart.yaml | truecharts-deconz-chart.md |
| https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/Dockerfile | deconz-docker-dockerfile.md |
| https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/download-deconz.sh | deconz-docker-download-script.md |
| https://github.com/dresden-elektronik/deconz-rest-plugin/releases/tag/v2.33.2 (HTML fallback) | deconz-rest-plugin-release.md |

Skipped: github.com blob Dockerfile (same as raw), marthoc/docker-deconz repo (other project, not a source for this build), phoscon.de/rest (REST API doc, not build input), phoscon.de and dresden-elektronik.de vendor pages (no build data), http://deconz.dresden-elektronik.de download URLs (binary, not fetched), no Docker Hub URL in urls.txt.

Failures:
- https://api.github.com/repos/dresden-elektronik/deconz-rest-plugin: HTTP 403. One alternative (HTML releases tag page) used; release date and tag confirmed, asset list not recovered.

## plan.md corrections
None. Verified in this run (plan.md notes these as UNVERIFIED; no edit made):
- Upstream default ports DECONZ_WEB_PORT=80 and DECONZ_WS_PORT=443 (plan lines 17, 18, 102, 140): confirmed by deconz-docker-dockerfile.md.
- Upstream UID/GID 1000/1000 (plan line 18): confirmed.
