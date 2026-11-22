# traggo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: traggo
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/traggo/server
- **Documentation**: https://traggo.net/install/
- **Website**: https://traggo.net/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: traggo
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/traggo/server:0.8.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/traggo/server/blob/6321119c3c2d55f04e2e4967f6492aabd6067b76/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/traggo/server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/traggo/server/releases/download/v0.8.3/traggo_0.8.3_linux_amd64.tar.gz) · [arm64](https://github.com/traggo/server/releases/download/v0.8.3/traggo_0.8.3_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go server shipped as release tarballs for linux amd64 and arm64, so ContainerForge can copy the binary into /app and run it. Data goes to /config, and it is a single process with no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [traggo/server:0.8.3](https://hub.docker.com/r/traggo/server)
- **copy-from arm64**: [traggo/server:0.8.3](https://hub.docker.com/r/traggo/server)

### Dependency containers

- **Dependency containers**: none
