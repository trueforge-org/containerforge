# kerio-connect

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: kerio-connect
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://www.kerio.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kerio-connect
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/chvb/docker-kerio-connect:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/chvb/docker-kerio-connect/blob/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.kerio.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.kerio.com/dwn/kerio-connect-linux-64bit.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Kerio Connect mail server installed from a vendor .deb on ubuntu 14.04, a multi-service mail stack that expects root and privileged ports. Rootless and read-only operation need significant rework, and the vendor product is legacy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [chvb/docker-kerio-connect:latest](https://hub.docker.com/r/chvb/docker-kerio-connect)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
