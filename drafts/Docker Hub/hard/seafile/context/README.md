# context: seafile

| Source URL | File |
| --- | --- |
| https://github.com/haiwen/seafile-docker/blob/7880bf3/image/seafile_14.0/Dockerfile (and full-sha variant, same commit) | upstream-dockerfile-14.0.md |
| https://github.com/haiwen/seafile-server (+ api.github.com releases/latest) | seafile-server-repo.md |
| https://hub.docker.com/r/seafileltd/seafile-mc | dockerhub-seafile-mc.md |
| https://seafile.com (www.seafile.com not fetched separately, same site) | seafile-com.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/seafile (+ values.yaml raw) | truecharts-seafile.md |
| https://manual.seafile.com | FAILED (see below) |

Skipped categories: CLA (cla-assistant link not in urls.txt; none), forgetool schemas (none), containerforge apps links (none), templated (none), binary downloads (none), image refs (none).

## Failures
- https://manual.seafile.com/docker/deploy_seafile_with_docker/ : 404. Alternative https://manual.seafile.com/ : redirect only to latest/, no content. Alternative https://manual.seafile.com/latest/docker/deploy_seafile_with_docker/ : 404. Env/port/volume facts from the manual are therefore UNVERIFIED.
- raw.githubusercontent.com/haiwen/seafile-server/master/README.md : 404 (repo HTML page used instead).

## plan.md corrections
- none applied (no proven factual error fixed in place).
- UNVERIFIED conflict: plan pins 14.0.9 (`v14.0.9-server`); TrueCharts values.yaml pins `14.0.11`; Docker Hub page lists only `14.0-latest`; GitHub releases/latest flag returns `v7.1.1-server`. Plan's 14.0.9 tag/date not confirmed by fetched sources.
- Plan's description of upstream Dockerfile (Ubuntu 24.04, phusion, nginx.org repo, pip pins, COPY --chmod=777, EXPOSE 80, CMD my_init enterpoint.sh) matches the fetched file.
