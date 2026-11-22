# ciao

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: ciao
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ciao
- **Source repository**: https://github.com/brotandgames/ciao

## Potentially relevant resources

- **Website**: https://brotandgames.com/ciao
- **Container image**: https://hub.docker.com/r/brotandgames/ciao

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Ruby is not provided by any base, so ubuntu is used with Ruby from apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ciao
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/brotandgames/ciao:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/brotandgames/ciao/blob/2ae06d337c5f8e669273228852613575cdb91e2d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/brotandgames/ciao)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/brotandgames/ciao/archive/refs/tags/1.12.0.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Ruby web app whose bundle is built in a ruby builder stage and copied with gems into a slim runtime. Ruby is not a ContainerForge base, so add it via apt on containerforge-ubuntu; gems are installed from rubygems and the app is a single process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [brotandgames/ciao:latest](https://hub.docker.com/r/brotandgames/ciao)
- **copy-from arm64**: [brotandgames/ciao:latest](https://hub.docker.com/r/brotandgames/ciao)

### Dependency containers

- **Dependency containers**: none
