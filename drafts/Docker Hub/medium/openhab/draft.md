# openhab

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: openhab
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openhab
- **Source repository**: https://github.com/openhab/openhab-distro
- **Documentation**: https://www.openhab.org/docs/
- **Website**: https://www.openhab.org

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/openhab/openhab

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: java21
- **Reason**: The input names java21 for a Java distro run from /app.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openhab
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/openhab/openhab:5.2.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/openhab/openhab-docker/blob/045c5cfacb270a668f3384990b4dcc91235d109f/debian/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/openhab/openhab-distro)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/openhab/openhab-distro/releases/download/5.2.5/openhab-5.2.5.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java app distributed as a noarch zip of the openHAB distro, so the java21 sibling runs it from /app. State and add-ons go in /config, and the image adds a few helper scripts. Several Karaf services run in one JVM, which needs care but is not a multi-process image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [openhab/openhab:5.2.5](https://hub.docker.com/r/openhab/openhab)
- **copy-from arm64**: [openhab/openhab:5.2.5](https://hub.docker.com/r/openhab/openhab)

### Dependency containers

- **Dependency containers**: none
