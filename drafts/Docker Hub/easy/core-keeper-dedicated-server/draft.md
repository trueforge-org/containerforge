# core-keeper-dedicated-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: core-keeper-dedicated-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/core-keeper-dedicated-server
- **Website**: https://store.steampowered.com/app/1963720/

## Potentially relevant resources

- **Source code repository**: https://github.com/escapingnetwork/core-keeper-dedicated
- **Container image**: https://hub.docker.com/r/escaping/core-keeper-dedicated

## Base container

- **Primary**: steamcmd
- **Alternative**: none
- **Reason**: Dedicated server downloaded as a Steam depot through SteamCMD.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: core-keeper-dedicated-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/escaping/core-keeper-dedicated:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/escapingnetwork/core-keeper-dedicated/blob/5448b12a4f7e3d066b76dc3b3b6d5cda820d8813/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://store.steampowered.com/app/1963720/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://store.steampowered.com/app/1963720/)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Dedicated server is a Steam depot download, so reuse the ContainerForge steamcmd app and fetch app 1963720 into /app at start or build time. Single game process with saves in /config. Only the x86-64 depot exists, so arm64 would not run natively.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [escaping/core-keeper-dedicated:latest](https://hub.docker.com/r/escaping/core-keeper-dedicated)
- **copy-from arm64**: [escaping/core-keeper-dedicated:latest](https://hub.docker.com/r/escaping/core-keeper-dedicated)

### Dependency containers

- **Dependency containers**: none
