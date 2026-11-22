# universal-media-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: universal-media-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/UniversalMediaServer/UniversalMediaServer

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: universal-media-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/universalmediaserver/ums:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/UniversalMediaServer/UniversalMediaServer/blob/main/src/main/external-resources/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/UniversalMediaServer/UniversalMediaServer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-x86_64.AppImage) · [arm64](https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-arm64.tgz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java media server (UMS) with a Dockerfile on ubuntu:22.04 that installs a JRE and the app. It can run on the java sibling with ffmpeg from apt, and state goes to /config. It writes to its home dir, so paths need redirecting to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [universalmediaserver/ums:latest](https://hub.docker.com/r/universalmediaserver/ums)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
