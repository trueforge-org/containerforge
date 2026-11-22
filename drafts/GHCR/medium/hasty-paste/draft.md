# hasty-paste

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: hasty-paste
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hasty-paste
- **Source repository**: https://github.com/enchant97/hasty-paste

## Potentially relevant resources

- **Container image**: https://ghcr.io/enchant97/hasty-paste
- **Source code repository**: https://github.com/enchant97/hasty-paste/blob/main/docs/install.md

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go backend is the runtime process; the node frontend is built in a builder stage.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hasty-paste
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/enchant97/hasty-paste:2.5.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/enchant97/hasty-paste/blob/ad6a831789716dfdfde3a68e22ff5bb2ef1b0851/app/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/enchant97/hasty-paste)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go backend plus a node-built web frontend; upstream copies both into a distroless static image. On containerforge-ubuntu we build the Go binary and frontend in a builder stage, copy them into /app and keep uploads under /config. One process and no database is required, so the work is a modest two-language build.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/enchant97/hasty-paste:2.5.1](https://ghcr.io/enchant97/hasty-paste)
- **copy-from arm64**: [ghcr.io/enchant97/hasty-paste:2.5.1](https://ghcr.io/enchant97/hasty-paste)

### Dependency containers

- **Dependency containers**: none
