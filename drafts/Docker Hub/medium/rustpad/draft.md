# rustpad

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: rustpad
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rustpad
- **Source repository**: https://github.com/ekzhang/rustpad

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ekzhang/rustpad

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rustpad
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ekzhang/rustpad:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ekzhang/rustpad/blob/54e4a9383c84d7317af42a7ddb177ce8bcba058d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ekzhang/rustpad)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Rust server built with cargo plus a Node frontend build copied in as dist. Single process with no services, but it needs a Rust toolchain and node added to the build stage on containerforge-ubuntu. Output is a native binary, so the image is per-arch.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ekzhang/rustpad:latest](https://hub.docker.com/r/ekzhang/rustpad)
- **copy-from arm64**: [ekzhang/rustpad:latest](https://hub.docker.com/r/ekzhang/rustpad)

### Dependency containers

- **Dependency containers**: none
