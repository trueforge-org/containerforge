# feedcord

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: feedcord
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/feedcord
- **Source repository**: https://github.com/Qolors/FeedCord

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/qolors/feedcord

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: .NET 9 app with the dotnet runtime from ubuntu apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: feedcord
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `qolors/feedcord:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Qolors/FeedCord/blob/c9568b968505c2979b5123f9d84262fe0d65dd85/FeedCord/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Qolors/FeedCord)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: .NET 9 app built with dotnet publish and run on the aspnet runtime; ContainerForge has no .NET base so the port needs the dotnet runtime from Ubuntu apt or Microsoft tarball. Config under /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [qolors/feedcord:latest](https://hub.docker.com/r/qolors/feedcord)
- **copy-from arm64**: [qolors/feedcord:latest](https://hub.docker.com/r/qolors/feedcord)

### Dependency containers

- **Dependency containers**: none
