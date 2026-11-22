# meshroom

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: very-hard
- **Chart**: meshroom
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/meshroom
- **Source repository**: https://github.com/alicevision/Meshroom
- **Documentation**: https://meshroom.readthedocs.io/en/stable/

## Potentially relevant resources

- **Source code repository**: https://github.com/alicevision/meshroom
- **Container image**: https://hub.docker.com/r/alicevision/meshroom

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt Linux tarball with bundled libraries unpacked onto ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libgl1 (inferred)
- python/pip: none
- node/npm: none
- other: Meshroom 2025.1.0 Linux tarball (amd64 only, bundles CUDA libs)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web desktop, inferred)

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
