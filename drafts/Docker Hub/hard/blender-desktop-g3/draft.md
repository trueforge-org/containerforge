# blender-desktop-g3

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: blender-desktop-g3
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/blender-desktop-g3
- **Source repository**: https://github.com/blender/blender
- **Documentation**: https://docs.blender.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/accetto/headless-drawing-g3
- **Container image**: https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-blender-g3

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single apt package on a VNC desktop stack.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: blender (arm64 path per spec), xfce4 desktop and VNC server (inferred)
- python/pip: none
- node/npm: none
- other: blender-5.0.1 tarball from download.blender.org (amd64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6901/http (noVNC web desktop, inferred), 5901/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/blender-desktop-g3
- non-root: possible - chart sets runAsUser 0; draft flags rootless operation as the main rework
- read-only-rootfs: possible - chart sets false; desktop writes to home paths
- privileged: no - not set, common default false
- other-security: none in values (no GPU device set)
- extra-persistence: /srv/projects (pvc) and /UNRAID_SHARE (pvc), both chart mounts
- confidence: medium

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
