# prusaslicer-novnc

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: prusaslicer-novnc
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/prusaslicer-novnc
- **Source repository**: https://github.com/prusa3d/PrusaSlicer

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mikeah/prusaslicer-novnc
- **Website**: https://www.prusa3d.com/prusaslicer

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop slicer package installed from apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: prusa-slicer, xvfb (inferred), libgl1-mesa-dri (inferred)
- python/pip: none
- node/npm: none
- other: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: prusaslicer-novnc
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mikeah/prusaslicer-novnc:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/helfrichmichael/prusaslicer-novnc/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/prusa3d/PrusaSlicer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:prusa-slicer`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: apt prusa-slicer 2.9.4 on containerforge-ubuntu for both architectures (older than 2.9.7). Desktop GUI needs kasmvnc or xvfb with GL libraries and rootless rework; settings and projects under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [mikeah/prusaslicer-novnc:latest](https://hub.docker.com/r/mikeah/prusaslicer-novnc)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
