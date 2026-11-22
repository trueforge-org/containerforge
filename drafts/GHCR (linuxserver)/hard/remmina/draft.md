# remmina

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: remmina
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/remmina
- **Source repository**: https://github.com/FreeRDP/Remmina

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/remmina
- **Source code repository**: https://github.com/linuxserver/docker-remmina
- **Website**: https://remmina.org

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop client installed with apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: remmina | none
- python/pip: none | none
- node/npm: none | none
- other: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: remmina
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/remmina:1.4.43`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-remmina/blob/9c34e90f8d44/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/FreeRDP/Remmina)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:remmina`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: GTK RDP and VNC client run inside a Selkies desktop image. The apt package remmina installs for amd64 and arm64 on Ubuntu, but a desktop image needs a VNC stack and rootless rework for the read-only rootfs, so it is hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/remmina:1.4.43](https://ghcr.io/linuxserver/remmina)
- **copy-from arm64**: [ghcr.io/linuxserver/remmina:1.4.43](https://ghcr.io/linuxserver/remmina)

### Dependency containers

- **Dependency containers**: none
