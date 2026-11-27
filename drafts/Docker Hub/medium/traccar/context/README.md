# Context index: traccar

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traccar/values.yaml | truecharts-traccar.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traccar/Chart.yaml | truecharts-traccar.md |
| https://hub.docker.com/v2/repositories/traccar/traccar/ | dockerhub-traccar.md |
| https://hub.docker.com/v2/repositories/traccar/traccar/tags?page_size=10 | dockerhub-traccar.md |
| https://raw.githubusercontent.com/traccar/traccar/master/docker/Dockerfile.alpine | github-traccar-dockerfile.md |
| https://www.traccar.org/documentation | traccar-docs.md (index only; the Docker and config pages below are the content) |
| https://www.traccar.org/docker/ (follow-up, same site) | traccar-docs.md |
| https://www.traccar.org/configuration-file/ (follow-up, same site) | traccar-docs.md |

Skipped categories: GitHub HTML pages (`github.com/traccar/traccar`, `blob/45ae732.../docker/Dockerfile.alpine`) covered by the raw master Dockerfile (the pinned-commit raw URL is the same path and was not fetched).

Failures: none.

## plan.md corrections
None edited. Checked and consistent: appVersion 6.17.0 and tag 6.17; web port 8082 (chart, EXPOSE in plan); Dockerfile.alpine content (`traccar-other-$VERSION.zip` input, jlink from temurin 25, `tracker-server.jar`, `conf/traccar.xml`); docs confirm `CONFIG_USE_ENVIRONMENT_VARIABLES` and the `/opt/traccar/data`, `/opt/traccar/logs`, `/opt/traccar/conf/traccar.xml` mounts.
Unverified (not edited): plan line 18 `web.port` default in Keys.java (not fetched); plan line 17 mention of the release zip asset names (release API not fetched); license (LICENSE not fetched).
