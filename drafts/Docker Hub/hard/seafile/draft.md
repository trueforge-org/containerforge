# seafile

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: seafile
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/seafile
- **Source repository**: https://github.com/haiwen/seafile-server
- **Documentation**: https://manual.seafile.com/
- **Website**: https://www.seafile.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: seafile
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/seafileltd/seafile-mc:14.0.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/haiwen/seafile-docker/blob/7880bf35bc8e66ee82237b6f6052ebe9803eeace/image/seafile_14.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/haiwen/seafile-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Seafile is several services in one image (ccnet, seafile server, seahub, fileserver) plus MariaDB and valkey dependencies, with an ubuntu base and root setup. Rootless operation and split processes are substantial rework. Official tarball is x86_64 only.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [seafileltd/seafile-mc:14.0.9](https://hub.docker.com/r/seafileltd/seafile-mc)
- **copy-from arm64**: [seafileltd/seafile-mc:14.0.9](https://hub.docker.com/r/seafileltd/seafile-mc)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅, valkey ✅
