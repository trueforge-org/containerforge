# fenrus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: fenrus
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/revenz/Fenrus

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fenrus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/revenz/fenrus:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/revenz/Fenrus/blob/fc8f57ac9d5643d16f7d8427f8341397e645f501/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/revenz/Fenrus)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: ASP.NET 10 dashboard built from source with dotnet, so the SDK or runtime must be added on ubuntu. The Dockerfile copies a prebuilt build folder, so a clean build is needed. Keep the database under /config and run rootless.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [revenz/fenrus:latest](https://hub.docker.com/r/revenz/fenrus)
- **copy-from arm64**: [revenz/fenrus:latest](https://hub.docker.com/r/revenz/fenrus)

### Dependency containers

- **Dependency containers**: none
