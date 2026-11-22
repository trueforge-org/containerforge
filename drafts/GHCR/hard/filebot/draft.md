# filebot

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: filebot
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://www.filebot.net/
- **Documentation**: https://www.filebot.net/getting-started/index.html

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: filebot
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jlesage/filebot:v26.09.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jlesage/docker-filebot/blob/v26.09.2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.filebot.net/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://get.filebot.net/filebot/FileBot_5.3.0/FileBot_5.3.0_amd64.deb) · [arm64](https://get.filebot.net/filebot/FileBot_5.3.0/FileBot_5.3.0-portable.tar.xz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: FileBot portable tarball from get.filebot.net, a JVM application with native MediaInfo and UnRAR libraries built from source. It runs as a Java GUI on a jlesage Alpine base over VNC. The desktop image and the native library builds make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
