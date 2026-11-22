# peanut

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: peanut
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/peanut
- **Source repository**: https://github.com/Brandawg93/PeaNUT

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/brandawg93/peanut

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Next.js app built with pnpm, so python-node provides node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: peanut
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/brandawg93/peanut:6.1.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Brandawg93/PeaNUT/blob/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Brandawg93/PeaNUT)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Brandawg93/PeaNUT/releases/tag/v6.1.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Next.js NUT dashboard built with pnpm in a builder stage and copied into a Node runner, so it needs the node sibling and a build step. Single process that reads config from environment; runs rootless with state in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [brandawg93/peanut:6.1.2](https://hub.docker.com/r/brandawg93/peanut)
- **copy-from arm64**: [brandawg93/peanut:6.1.2](https://hub.docker.com/r/brandawg93/peanut)

### Dependency containers

- **Dependency containers**: none
