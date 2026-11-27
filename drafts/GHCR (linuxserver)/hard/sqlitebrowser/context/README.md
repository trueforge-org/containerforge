# Context: sqlitebrowser

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sqlitebrowser/values.yaml + Chart.yaml | truecharts-sqlitebrowser.md |
| https://hub.docker.com/v2/repositories/linuxserver/sqlitebrowser/ (not in urls.txt; added per REQUIRED Docker Hub rule) | dockerhub-sqlitebrowser.md |
| https://raw.githubusercontent.com/linuxserver/docker-sqlitebrowser/07d24df2caea/Dockerfile | linuxserver-dockerfile.md |
| https://api.github.com/repos/sqlitebrowser/sqlitebrowser/releases/latest (403), fallback https://github.com/sqlitebrowser/sqlitebrowser/releases/latest | upstream-release.md |
| https://sqlitebrowser.org + https://raw.githubusercontent.com/sqlitebrowser/sqlitebrowser/master/LICENSE | upstream-website.md |

Skipped: github.com repo/blob duplicates of the Dockerfile and linuxserver repo (same content); sqlitebrowser wiki (not fetched, budget); packages.ubuntu.com (not fetched, covered by plan/PPA). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in list.

Failures: api.github.com releases/latest returned 403; fallback HTML page used.

## plan.md corrections
- None. Plan release date 2024-10-16 is consistent with the sqlitebrowser.org blog. Ubuntu archive version (3.13.1-1) and Hub digest in plan not verified.
