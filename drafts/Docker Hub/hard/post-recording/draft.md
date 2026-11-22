# post-recording

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: post-recording
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/post-recording
- **Source repository**: https://github.com/erikkaashoek/Comskip

## Potentially relevant resources

- **Source code repository**: https://github.com/chacawaca/docker-post-recording
- **Container image**: https://hub.docker.com/r/chacawaca/post-recording

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Compiled native tools and ffmpeg installed on ubuntu with no interpreted runtime.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: post-recording
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/chacawaca/post-recording:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/chacawaca/docker-post-recording/blob/971031f2ba851a003d762c1ee9aa523100a90b4b/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/erikkaashoek/Comskip)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/erikkaashoek/Comskip/releases/tag/V0.83)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Ubuntu 20.04 image that compiles comskip and comchap from git, copies ffmpeg and ccextractor from other images and adds an s6 overlay running several processes. Several services plus several compiled tools make this hard even though the code is open.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [chacawaca/post-recording:latest](https://hub.docker.com/r/chacawaca/post-recording)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
