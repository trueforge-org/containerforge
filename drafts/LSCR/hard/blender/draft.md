# blender

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: LSCR
- **Difficulty**: hard
- **Chart**: blender
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/blender
- **Source repository**: https://github.com/blender/blender
- **Documentation**: https://docs.blender.org/manual/en/latest/

## Potentially relevant resources

- **Container image**: https://fleet.linuxserver.io/image?name=linuxserver/blender
- **Source code repository**: https://github.com/linuxserver/docker-blender#readme
- **Source code repository**: https://github.com/orgs/linuxserver/packages/container/package/blender
- **Website**: https://www.blender.org

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Desktop GUI application installed from the Blender tarball or apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: blender
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `lscr.io/linuxserver/blender:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-blender/blob/16e1a2aec1d331f2a4462eb52538b99d6d1c2932/Dockerfile)

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

- **Reason**: Blender GUI on a linuxserver selkies desktop base, so a desktop/VNC-style image. Official tarball is x64 only but Ubuntu ships blender for arm64 via apt; desktop session setup and GPU needs drive the difficulty.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [lscr.io/linuxserver/blender:latest](https://ghcr.io/linuxserver/blender)
- **copy-from arm64**: [lscr.io/linuxserver/blender:latest](https://ghcr.io/linuxserver/blender)

### Dependency containers

- **Dependency containers**: none
