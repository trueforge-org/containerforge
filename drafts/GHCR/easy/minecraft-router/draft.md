# minecraft-router

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: minecraft-router
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minecraft-router
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/itzg/mc-router:1.56.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/itzg/mc-router/blob/bc9198334912/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/itzg/mc-router)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/itzg/mc-router/releases/download/v1.56.5/mc-router_1.56.5_linux_amd64.tar.gz) · [arm64](https://github.com/itzg/mc-router/releases/download/v1.56.5/mc-router_1.56.5_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single static Go binary (go build of cmd/mc-router) copied onto a minimal base, with no services and no state beyond routing config. On ubuntu, copy the released binary into /app and run it rootless with a high port. Easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/itzg/mc-router:1.56.5](https://ghcr.io/itzg/mc-router)
- **copy-from arm64**: [ghcr.io/itzg/mc-router:1.56.5](https://ghcr.io/itzg/mc-router)

### Dependency containers

- **Dependency containers**: none
