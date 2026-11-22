# meshroom

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: very-hard
- **Chart**: meshroom
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/alicevision/Meshroom
- **Documentation**: https://meshroom.readthedocs.io/en/stable/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: meshroom
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/alicevision/meshroom:2025.1.0-av3.3.0-ubuntu22.04-cuda12.1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alicevision/meshroom/blob/v2025.1.0/docker/Dockerfile_ubuntu)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/alicevision/Meshroom)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://zenodo.org/records/16887472/files/Meshroom-2025.1.0-Linux.tar.gz)

### Difficulty

`very-hard`: closed source with no redistributable artifact, or kernel/host-level tools.

- **Difficulty**: very-hard

### Reason

- **Reason**: Meshroom 2025.1.0 Linux tarball (14 GB, bundles AliceVision and CUDA 12 libs) unpacked on containerforge-ubuntu for amd64 only. Useful only with an NVIDIA GPU and large /config workspace; no arm64 route exists.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [alicevision/meshroom:2025.1.0-av3.3.0-ubuntu22.04-cuda12.1.1](https://hub.docker.com/r/alicevision/meshroom)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
