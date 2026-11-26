# openaudible context

| Source URL | File |
| --- | --- |
| https://github.com/openaudible/openaudible_docker (raw README) | openaudible-docker-readme.md |
| https://github.com/openaudible/openaudible_docker/blob/master/Dockerfile | openaudible-docker-dockerfile.md |
| https://openaudible.org/swt_version.json | openaudible-swt-version.md |
| https://openaudible.org | openaudible-org.md |
| https://openaudible.org/documentation | openaudible-documentation.md |
| https://hub.docker.com/r/openaudible/openaudible | dockerhub-openaudible.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openaudible (values.yaml) | truecharts-openaudible-values.md |

Skipped:
- https://openaudible.org/latest/linux_x86_64_deb: binary package download (redirects to GitHub .deb); not fetched.

Failures: none.

## plan.md corrections
- None made. Plan's version 5.3, release date, port 3000, /config/OpenAudible and kasmvnc base agree with fetched sources.
- Conflict (no edit): Docker Hub page says the image is built on linuxserver webtop (Ubuntu), while the Dockerfile uses `baseimage-kasmvnc:debianbookworm` (plan follows the Dockerfile).
- Unverified (no edit): plan's SHA256 values for the deb were not re-read from the manifest here.
