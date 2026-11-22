# filezilla

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: filezilla
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filezilla
- **Website**: https://filezilla-project.org/
- **Documentation**: https://wiki.filezilla-project.org/Documentation
- **Website**: https://filezilla-project.org

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/filezilla
- **Source code repository**: https://github.com/linuxserver/docker-filezilla

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: GTK client installed as one apt package on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: filezilla
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/filezilla:3.69.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-filezilla/blob/ad89ad1bdd0f2bad2d7dd8a68a3f989c3449949f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://filezilla-project.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:filezilla`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: GTK FTP client run as a Selkies desktop image in the linuxserver wrapper. The app is a single apt package available on both arches, but a desktop image with a VNC stack and root-free rework for a read-only rootfs makes it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/filezilla:3.69.6](https://ghcr.io/linuxserver/filezilla)
- **copy-from arm64**: [ghcr.io/linuxserver/filezilla:3.69.6](https://ghcr.io/linuxserver/filezilla)

### Dependency containers

- **Dependency containers**: none
