# digikam

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: digikam
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/digikam
- **Source repository**: https://github.com/KDE/digikam
- **Documentation**: https://docs.digikam.org/
- **Website**: https://www.digikam.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/digikam
- **Source code repository**: https://github.com/linuxserver/docker-digikam

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: digikam
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/digikam:9.1.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-digikam/blob/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/KDE/digikam)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:digikam`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: digiKam Qt6 photo manager downloaded as an AppImage from the KDE mirror and run on a linuxserver selkies desktop base. The large Qt and KDE stack and the desktop/VNC image make it hard. Linuxserver ships amd64 only.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/linuxserver/digikam:9.1.0](https://ghcr.io/linuxserver/digikam)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
