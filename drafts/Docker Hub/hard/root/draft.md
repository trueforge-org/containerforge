# root

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: root
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/root
- **Source repository**: https://github.com/root-project/root
- **Documentation**: https://root.cern/manual/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bgameiro/arch-cern-root
- **Website**: https://root.cern

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: python
- **Reason**: C++ analysis framework installed from apt on ubuntu; the notebook server could use the python base as the alternative.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: root
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bgameiro/arch-cern-root:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/BGameiro2000/dockerfile/blob/master/arch-cern-root/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/root-project/root)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/root-project/root/releases/download/v6-40-04/root_v6.40.04.Linux-ubuntu26.04-x86_64-gcc15.2.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: CERN ROOT plus Jupyter, installed with pacman on Arch. ROOT is a large C++ stack and Jupyter is a second server process. On containerforge-ubuntu we would use apt root-system with a Jupyter service, plus /config and /tmp for writes.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [bgameiro/arch-cern-root:latest](https://hub.docker.com/r/bgameiro/arch-cern-root)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
