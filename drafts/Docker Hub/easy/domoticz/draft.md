# domoticz

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: domoticz
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/domoticz/domoticz
- **Documentation**: https://wiki.domoticz.com/
- **Website**: https://www.domoticz.com

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: domoticz
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/domoticz/domoticz:2026.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/domoticz/domoticz-docker/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/domoticz/domoticz)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/domoticz/domoticz/releases/download/2026.4/domoticz_linux_x86_64.tgz) · [arm64](https://github.com/domoticz/domoticz/releases/download/2026.4/domoticz_linux_aarch64.tgz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Prebuilt Domoticz release tarball (2026.4) for x86_64 and aarch64, shipped as a single C++ server with a web UI. Install on containerforge-ubuntu, store the database in /config, and leave out optional Z-Wave or serial hardware.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [domoticz/domoticz:2026.4](https://hub.docker.com/r/domoticz/domoticz)
- **copy-from arm64**: [domoticz/domoticz:2026.4](https://hub.docker.com/r/domoticz/domoticz)

### Dependency containers

- **Dependency containers**: none
