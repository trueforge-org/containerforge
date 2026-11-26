# Context: wisemapping

| Source URL | File |
| --- | --- |
| https://bitbucket.org/wisemapping/wisemapping-open-source/src/develop | FAILED (raw README 404); GitHub mirror used: wisemapping-open-source-readme.md |
| https://github.com/wisemapping/wisemapping-open-source | wisemapping-open-source-readme.md |
| https://github.com/wisemapping/wisemapping-open-source/blob/5099d14e6290138a97f599079eaf42daa2d2ad3c/distribution/app/Dockerfile | wisemapping-app-dockerfile.md (also start.sh, nginx.conf) |
| https://github.com/wisemapping/wisemapping-frontend | wisemapping-frontend-readme.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wisemapping | truecharts-wisemapping-chart.md |
| https://hub.docker.com/r/wisemapping/wisemapping | dockerhub-and-website.md |
| https://www.wisemapping.com | dockerhub-and-website.md |

Skipped categories: none (urls.txt pre-filtered).

Failures:
- bitbucket.org raw README: 404 (one alternative tried: GitHub mirror of the same repo, fetched).
- Docker Hub page is JS-rendered: only title and description recorded.

## plan.md corrections
- L11 License: "WiseMapping Public License 1.0" -> "WiseMapping Open License, Version 1.0" (source: upstream README, raw GitHub develop). The SPDX identifier `LicenseRef-WiseMapping-WPL-1.0` (plan L11, L65) is not verified against the upstream text; left unchanged.
- Unverified conflicts (not edited):
  - plan L16 says `packageManager` is `yarn@4.18.1` at 6.0.11; not checked (fetched Dockerfile uses `yarn@4.13.0` corepack prepare).
  - truecharts chart (`values.yaml`) is Tomcat-era (WEB-INF app.properties, port 8080); does not match the upstream Dockerfile at 5099d14 (nginx port 80). Not a plan error, but do not copy chart layout.
