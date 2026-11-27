# Context index: teedy

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teedy/values.yaml | truecharts-teedy.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teedy/Chart.yaml | truecharts-teedy.md |
| https://hub.docker.com/v2/repositories/sismics/docs/ | dockerhub-teedy.md |
| https://hub.docker.com/v2/repositories/sismics/docs/tags?page_size=10 | dockerhub-teedy.md |
| https://raw.githubusercontent.com/sismics/docs/master/Dockerfile | github-teedy-dockerfile.md |
| https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/12.1.6 | maven-jetty-home.md |

Skipped categories: GitHub HTML pages (`github.com/sismics/docs`, `blob/5b39c46/Dockerfile`) covered by the raw master Dockerfile (the commit-pinned raw URL was not in the list and was not fetched).

Failures:
- https://api.github.com/repos/sismics/docs/releases/latest: HTTP 403 (API rate limit). Single attempt, not retried; no alternative fetched.

## plan.md corrections
None edited. Checked and consistent: v1.12 tag and 2026-11-23 date (Docker Hub); master Dockerfile content (ubuntu:26.04, openjdk-25, ffmpeg, mediainfo, tesseract, Jetty 12.1.6 from Maven, EXPOSE 8080, CMD java -jar /opt/jetty/start.jar, env list); Maven Jetty 12.1.6 tarball and checksum files exist.
Unverified (not edited): GPL-2.0 license (LICENSE not fetched); WAR asset name `docs-web-1.12.war` (release API rate-limited); docs.xml `docs.home=/data` (raw file not fetched in this pass).
