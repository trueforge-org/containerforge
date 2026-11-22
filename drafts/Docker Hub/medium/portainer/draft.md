# portainer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: portainer
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (portainer-ee (beImage))
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/portainer
- **Source repository**: https://github.com/portainer/portainer
- **Documentation**: https://docs.portainer.io/
- **Website**: https://www.portainer.io

## Potentially relevant resources

- **Website**: https://docs.portainer.io/start/install-ce/server
- **Website**: https://docs.portainer.io/start/install/server
- **Container image**: https://hub.docker.com/r/portainer/portainer-ce
- **Container image**: https://hub.docker.com/r/portainer/portainer-ee

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: portainer
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/portainer/portainer-ce:2.45.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/portainer/portainer/blob/505380c8eecff08cf513c457494bde91634db9ff/build/linux/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/portainer/portainer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/portainer/portainer/releases/download/2.45.4/portainer-2.45.4-linux-amd64.tar.gz) · [arm64](https://github.com/portainer/portainer/releases/download/2.45.4/portainer-2.45.4-linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go server (2.45.4) with prebuilt UI shipped in upstream release tarballs for linux amd64 and arm64, so no compile. Unpack into /app on containerforge-ubuntu, data in /config. Docker socket or agent access is a runtime concern; the EE image is not used.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [portainer/portainer-ce:2.45.4](https://hub.docker.com/r/portainer/portainer-ce)
- **copy-from arm64**: [portainer/portainer-ce:2.45.4](https://hub.docker.com/r/portainer/portainer-ce)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: portainer-ee (beImage) ❌
