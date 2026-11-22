# plaxt

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: plaxt
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plaxt
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/xanderstrike/goplaxt:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/XanderStrike/goplaxt/blob/1607349dea8ce7fb3b8e7ccfb0370d8103d31d61/Dockerfile-amd64)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/XanderStrike/goplaxt)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Small Go OAuth bridge built from source with an old golang 1.12 builder, and no release binaries exist. Compiling with a modern Go toolchain on containerforge-ubuntu is straightforward, and it is a single process. Both architectures compile from source.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [xanderstrike/goplaxt:latest](https://hub.docker.com/r/xanderstrike/goplaxt)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
