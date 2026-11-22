# z80pack

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: z80pack
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: z80pack
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/dlandon/z80pack:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/dlandon/z80pack/blob/ae67a0f2e18868f5ccc99eff31973183c4965aa6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/udo-munk/z80pack)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Open-source Z80/CP/M emulator built with make from source tarballs; on containerforge-ubuntu this is a build stage plus a small runtime with a web terminal or console wrapper. The phusion/runit root init goes away, so it is a modest source build with state in /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [dlandon/z80pack:latest](https://hub.docker.com/r/dlandon/z80pack)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
