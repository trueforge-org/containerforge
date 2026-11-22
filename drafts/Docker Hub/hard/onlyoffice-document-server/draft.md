# onlyoffice-document-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: onlyoffice-document-server
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/ONLYOFFICE/DocumentServer
- **Documentation**: https://helpcenter.onlyoffice.com/docs/
- **Website**: https://www.onlyoffice.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: onlyoffice-document-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/onlyoffice/documentserver:10.0.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ONLYOFFICE/DocumentServer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ONLYOFFICE/DocumentServer/releases/download/v10.0.0/onlyoffice-documentserver_amd64.deb) · [arm64](https://github.com/ONLYOFFICE/DocumentServer/releases/download/v10.0.0/onlyoffice-documentserver_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The vendor documentserver .deb is installed on ubuntu 24.04 and runs several services together: nginx, a Node backend, a converter, and a message broker, under supervisord with root. It also needs Postgres and Valkey, so a large multi-service stack must be reworked.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [onlyoffice/documentserver:10.0.0](https://hub.docker.com/r/onlyoffice/documentserver)
- **copy-from arm64**: [onlyoffice/documentserver:10.0.0](https://hub.docker.com/r/onlyoffice/documentserver)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql (CNPG) ✅
