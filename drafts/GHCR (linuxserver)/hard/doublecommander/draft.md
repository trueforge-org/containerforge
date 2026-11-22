# doublecommander

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: doublecommander
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/doublecommander
- **Source repository**: https://github.com/doublecmd/doublecmd
- **Documentation**: https://doublecmd.github.io/doc/en/help.html
- **Website**: https://doublecmd.sourceforge.io

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/doublecommander
- **Source code repository**: https://github.com/linuxserver/docker-doublecommander

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop file manager installed as one apt package on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: doublecommander
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/doublecommander:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-doublecommander/blob/05e15297277457b38b1c99c2207185cf73873f15/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/doublecmd/doublecmd)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/doublecmd/doublecmd/releases/download/v1.2.11/doublecmd-1.2.11.gtk2.x86_64.tar.xz) · [arm64](https://github.com/doublecmd/doublecmd/releases/download/v1.2.11/doublecmd-1.2.11.gtk2.aarch64.tar.xz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Qt/GTK desktop file manager shipped inside a Selkies desktop image that runs as root. The app is one apt package (doublecmd-gtk) that installs on containerforge-ubuntu for both arches, but a GUI desktop with a VNC stack needs a rootless rework for the read-only rootfs.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/doublecommander:latest](https://ghcr.io/linuxserver/doublecommander)
- **copy-from arm64**: [ghcr.io/linuxserver/doublecommander:latest](https://ghcr.io/linuxserver/doublecommander)

### Dependency containers

- **Dependency containers**: none
