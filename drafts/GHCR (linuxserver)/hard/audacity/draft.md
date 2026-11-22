# audacity

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: audacity
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/audacity/audacity
- **Documentation**: https://manual.audacityteam.org/
- **Website**: https://www.audacityteam.org/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: audacity
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/audacity:version-3.0.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-audacity/blob/b0c6f0d2e0d8650f40ef6e5a8661baa2230a5812/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/audacity/audacity)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/audacity/audacity/releases/download/Audacity-4.0.2/audacity-linux-4.0.2-x86_64.AppImage) · [arm64](https://github.com/audacity/audacity/releases/download/Audacity-4.0.2/audacity-linux-4.0.2-aarch64.AppImage)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Audacity desktop audio editor run from an AppImage on a linuxserver selkies desktop base with a browser-based GUI. The AppImage needs FUSE or extraction, and the desktop stack makes it hard. A distro apt package would avoid the AppImage.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/audacity:version-3.0.2](https://ghcr.io/linuxserver/audacity)
- **copy-from arm64**: [ghcr.io/linuxserver/audacity:version-3.0.2](https://ghcr.io/linuxserver/audacity)

### Dependency containers

- **Dependency containers**: none
