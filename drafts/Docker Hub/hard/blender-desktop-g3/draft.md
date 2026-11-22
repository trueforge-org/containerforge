# blender-desktop-g3

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: blender-desktop-g3
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/blender/blender
- **Documentation**: https://docs.blender.org/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: blender-desktop-g3
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/accetto/ubuntu-vnc-xfce-blender-g3:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/blender/blender)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.blender.org/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz) · arm64: `apt:blender`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Ubuntu XFCE desktop with VNC and Blender from apt. It needs a multi-process desktop stack that ContainerForge covers with the kasmvnc or xvfb siblings, and rootless operation with no GPU is the main rework. The app itself is one apt package.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [accetto/ubuntu-vnc-xfce-blender-g3:latest](https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-blender-g3)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
