# gridcoinwalletgui

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: gridcoinwalletgui
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/gridcoin-community/Gridcoin-Research

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gridcoinwalletgui
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sublivion/gridcoinwalletgui:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gridcoin-community/Gridcoin-Research)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/gridcoin-community/Gridcoin-Research/releases/download/5.5.2.0/gridcoin-5.5.2.0-x86_64.flatpak) · [arm64](https://github.com/gridcoin-community/Gridcoin-Research/releases/download/5.5.2.0/gridcoinresearch-qt_5.5.2.0.bookworm-2_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Qt desktop wallet run inside a VNC container, so it needs a GUI stack, X server and a VNC sibling such as kasmvnc or xvfb. The wallet itself has official x86_64 tarball and per-arch deb packages, so the install is simple. The desktop and VNC setup is the effort driver.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [sublivion/gridcoinwalletgui:latest](https://hub.docker.com/r/sublivion/gridcoinwalletgui)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
