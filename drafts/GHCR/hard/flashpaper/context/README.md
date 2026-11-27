# flashpaper context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flashpaper/values.yaml | truecharts-flashpaper-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flashpaper/Chart.yaml | truecharts-flashpaper-chart.md |
| https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/Dockerfile | flashpaper-dockerfile.md |
| https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/entrypoint.sh | flashpaper-entrypoint.md |
| https://github.com/AndrewPaglusch/FlashPaper/releases/tag/v2.6.0 and /releases/latest (API 403 alt) | flashpaper-releases.md |
| https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/nginx.conf (not in urls.txt; resolves plan.md port item) | flashpaper-nginx-conf.md |

Skipped: github.com blob Dockerfile (same as raw), github.com repo root (HTML; license MIT in plan.md), `github.com/andrewpaglusch/FlashPaper/pkgs/container/flashpaper` (GHCR package HTML, not fetched), archive tarball of v2.6.1 (binary source archive, not downloaded), the Docker Hub/GHCR image refs (image-ref category), no Docker Hub URL in urls.txt.

Failures:
- https://api.github.com/repos/AndrewPaglusch/FlashPaper/releases/latest: HTTP 403. One alternative (HTML releases/latest) used; v2.6.1 and date recovered.

## plan.md corrections
None edited. Verified:
- plan.md line 8: v2.6.1 published 2026-11-23 (HTML releases/latest datetime) and the draft's v2.6.0 is older (2026-10-22). Matches.
- plan.md line 19: listen port. The upstream docker/nginx.conf has `listen 80;` (fetched). The plan's "UNVERIFIED" note can now be resolved as 80. Not edited (not an error).
- plan.md line 33 says nginx.conf was not read yet; it is now (flashpaper-nginx-conf.md).
