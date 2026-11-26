# onlyoffice-document-server context

| Source URL | File |
| --- | --- |
| https://github.com/ONLYOFFICE/Docker-DocumentServer (raw master README) | docker-documentserver-readme.md |
| https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/Dockerfile | onlyoffice-dockerfile.md |
| https://github.com/ONLYOFFICE/DocumentServer (GitHub API latest release; README failed) | onlyoffice-documentserver-release-latest.md |
| https://helpcenter.onlyoffice.com/docs | onlyoffice-helpcenter-docs.md |
| https://hub.docker.com/r/onlyoffice/documentserver | dockerhub-onlyoffice-documentserver.md |
| https://www.onlyoffice.com | onlyoffice-com.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/onlyoffice-document-server (values.yaml) | truecharts-onlyoffice-values.md |

Skipped: none.

Failures:
- https://github.com/ONLYOFFICE/DocumentServer README: raw master 404; alternative raw main 404. Not retried further. Release info came from the API.

## plan.md corrections
- None made. Plan's v10.0.0, AGPL-3.0, ports 80/443, Dockerfile facts (ubuntu:24.04, DS_DOCKER_INSTALLATION, volumes, healthcheck) agree with fetched sources.
- Unverified conflict (no edit): Docker Hub page names `onlyoffice.key`/`onlyoffice.crt` for SSL, while the Docker-DocumentServer README and Dockerfile default to `tls.key`/`tls.crt`. Plan not checked for SSL file naming.
