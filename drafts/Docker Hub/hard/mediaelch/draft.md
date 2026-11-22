# mediaelch

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: mediaelch
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mediaelch
- **Source repository**: https://github.com/Komet/MediaElch
- **Documentation**: https://mediaelch.github.io/mediaelch-doc/about.html
- **Documentation**: https://github.com/Komet/MediaElch/wiki
- **Website**: https://www.mediaelch.de/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/masonxx/mediaelch

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mediaelch
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/masonxx/mediaelch:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Giftie/docker-mediaelch/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Komet/MediaElch)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Komet/MediaElch/releases/download/v2.12.0/MediaElch_linux_2.12.0_2024-10-13_git-8032465.AppImage)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Qt desktop GUI: amd64 uses the release AppImage (extracted, since FUSE is unavailable), arm64 needs a Qt6 CMake build from source. Runs only under a VNC or X desktop, so it needs kasmvnc/xvfb, /config for settings and rootless display handling.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [masonxx/mediaelch:latest](https://hub.docker.com/r/masonxx/mediaelch)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
