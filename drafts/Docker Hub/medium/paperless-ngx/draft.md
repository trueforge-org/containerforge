# paperless-ngx

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: paperless-ngx
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/paperless-ngx
- **Source repository**: https://github.com/apache/tika

## Potentially relevant resources

- **Container image**: https://ghcr.io/paperless-ngx/paperless-ngx
- **Source code repository**: https://github.com/paperless-ngx/paperless-ngx
- **Container image**: https://hub.docker.com/r/apache/tika
- **Container image**: https://hub.docker.com/r/gotenberg/gotenberg
- **Website**: https://paperless-ngx.readthedocs.io/en/latest

## Base container

- **Primary**: java21
- **Alternative**: java25
- **Reason**: Java tika-server jar; the input allows java21 or java25 and java21 is the conservative pick.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: paperless-ngx
- **Role**: sidecar (tikaImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/apache/tika:3.3.3.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/apache/tika-docker/blob/master/minimal/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/apache/tika)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://dlcdn.apache.org/tika/3.3.3/tika-server-standard-3.3.3.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java tika-server jar on Ubuntu; reuse ContainerForge java21/java25 base and download the jar from Apache. Minimal variant is easy, but the full variant needs tesseract and gdal/fonts. Runs rootless; needs only /tmp writable.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [apache/tika:3.3.3.1](https://hub.docker.com/r/apache/tika)
- **copy-from arm64**: [apache/tika:3.3.3.1](https://hub.docker.com/r/apache/tika)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
