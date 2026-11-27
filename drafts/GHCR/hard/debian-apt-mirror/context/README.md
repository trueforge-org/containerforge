# debian-apt-mirror context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/debian-apt-mirror/values.yaml | truecharts-debian-apt-mirror-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/debian-apt-mirror/Chart.yaml | truecharts-debian-apt-mirror-chart.md |
| https://raw.githubusercontent.com/ich777/docker-debian-mirror/master/Dockerfile | ich777-docker-debian-mirror-dockerfile.md |
| https://github.com/apt-mirror/apt-mirror/releases/latest (HTML fallback) | apt-mirror-release.md |
| https://manpages.debian.org/trixie/apt-mirror/apt-mirror.1.en.html | apt-mirror-manpage.md |
| https://raw.githubusercontent.com/apt-mirror/apt-mirror/master/LICENSE | apt-mirror-license.md |

Skipped: github.com blob URL of ich777 Dockerfile (same as raw), github.com repo page (HTML, covered by API/raw), debian.org home page (generic), no Docker Hub URL in urls.txt.

Failures:
- https://api.github.com/repos/apt-mirror/apt-mirror/releases/latest: HTTP 403. One alternative tried (github.com releases/latest HTML), used for version.
- https://api.github.com/repos/apt-mirror/apt-mirror: HTTP 403, not retried. Asset/publish-date info not recovered.

## plan.md corrections
None. Unverified in this run (not edited):
- plan.md line 8 publish date 2017-05-29 and Debian package 0.5.4-2 (API blocked; man page did not show package version).
- plan.md lines 19, 109, 143-144 `set base_path` / `mirror_path` / `var_path` keys (not found in the extracted man page text).
- plan.md line 18 `/etc/cron.d/apt-mirror` template (not in extracted text).
