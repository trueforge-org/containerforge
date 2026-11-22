# yacreaderlibraryserver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: yacreaderlibraryserver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/yacreaderlibraryserver
- **Source repository**: https://github.com/YACReader/yacreader

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: yacreaderlibraryserver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/xthursdayx/yacreaderlibrary-server-docker:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/xthursdayx/yacreaderlibrary-server-docker/blob/f1d5f1b9e32bc19d6ac06873e071ff67f332388a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/YACReader/yacreader)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: C++ Qt6 library server compiled from the YACReader source tag, with many Qt and image libraries. Upstream publishes only a source tarball plus macOS/Windows builds, so a heavy Qt build on both arches; read-only paths and library data go under /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/xthursdayx/yacreaderlibrary-server-docker:latest](https://ghcr.io/xthursdayx/yacreaderlibrary-server-docker)
- **copy-from arm64**: [ghcr.io/xthursdayx/yacreaderlibrary-server-docker:latest](https://ghcr.io/xthursdayx/yacreaderlibrary-server-docker)

### Dependency containers

- **Dependency containers**: none
